import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/auth/data/models/user_model.dart';

abstract class RemoteAuthDataSource {
  Stream<UserModel?> get userChanges;
  Stream<User?> get authStateChanges;
  String? get currentUserId;
  Future<UserCredential> signUpWithEmail(String email, String password);
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Future<bool> isUsernameAvailable(String username, {String? currentUid});
  Future<void> createUserProfile(UserModel user);
  Future<void> setUsername({required String uid, required String username});
  Future<UserModel> getUserProfile(String uid);
}

@LazySingleton(as: RemoteAuthDataSource)
class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  RemoteAuthDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
    this._googleSignIn,
  );
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _usernamesCollection =>
      _firestore.collection('usernames');

  @override
  Stream<UserModel?> get userChanges {
    late final StreamController<UserModel?> controller;
    StreamSubscription<User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    profileSubscription;

    controller = StreamController<UserModel?>(
      onListen: () {
        authSubscription = _firebaseAuth.authStateChanges().listen((
          firebaseUser,
        ) {
          profileSubscription?.cancel();
          profileSubscription = null;

          if (firebaseUser == null) {
            controller.add(null);
            return;
          }

          profileSubscription = _usersCollection
              .doc(firebaseUser.uid)
              .snapshots()
              .listen((doc) {
                if (!doc.exists) {
                  controller.add(
                    UserModel(
                      uid: firebaseUser.uid,
                      email: firebaseUser.email ?? '',
                      displayName: firebaseUser.displayName,
                      photoUrl: firebaseUser.photoURL,
                    ),
                  );
                  return;
                }

                controller.add(
                  UserModel.fromFirestore(doc, firebaseUser: firebaseUser),
                );
              }, onError: controller.addError);
        }, onError: controller.addError);
      },
      onCancel: () async {
        await profileSubscription?.cancel();
        await authSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in was cancelled by the user.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return _firebaseAuth.signOut();
  }

  @override
  Future<bool> isUsernameAvailable(
    String username, {
    String? currentUid,
  }) async {
    final usernameDoc = await _usernamesCollection.doc(username).get();
    if (!usernameDoc.exists) {
      return true;
    }

    final data = usernameDoc.data() ?? <String, dynamic>{};
    final ownerUid = data['uid'] as String?;
    return ownerUid != null && currentUid != null && ownerUid == currentUid;
  }

  @override
  Future<void> createUserProfile(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toFirestore());
  }

  @override
  Future<void> setUsername({
    required String uid,
    required String username,
  }) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null || firebaseUser.uid != uid) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user found.',
      );
    }

    final userRef = _usersCollection.doc(uid);
    final usernameRef = _usernamesCollection.doc(username);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final existingUsername = (userData['username'] as String? ?? '').trim();

      if (existingUsername.isNotEmpty && existingUsername != username) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'username-already-set',
          message: 'Username has already been set for this account.',
        );
      }

      final usernameSnapshot = await transaction.get(usernameRef);
      if (usernameSnapshot.exists) {
        final data = usernameSnapshot.data() ?? <String, dynamic>{};
        final ownerUid = data['uid'] as String?;
        if (ownerUid != uid) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'username-taken',
            message: 'Username is already taken.',
          );
        }
      }

      final userUpdate =
          <String, dynamic>{
            'username': username,
            'updatedAt': FieldValue.serverTimestamp(),
          }..addAll(
            !userSnapshot.exists
                ? {
                    'email': firebaseUser.email ?? '',
                    'displayName': firebaseUser.displayName ?? 'Reelio User',
                    'photoUrl': firebaseUser.photoURL,
                    'bio': '',
                    'reelsCount': 0,
                    'followerCount': 0,
                    'followingCount': 0,
                    'createdAt': FieldValue.serverTimestamp(),
                  }
                : {},
          );

      transaction
        ..set(userRef, userUpdate, SetOptions(merge: true))
        ..set(usernameRef, {
          'uid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    });
  }

  @override
  Future<UserModel> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) throw Exception('User profile not found');
    return UserModel.fromFirestore(doc);
  }
}
