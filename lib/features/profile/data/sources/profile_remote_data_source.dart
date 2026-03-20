import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/profile/data/models/profile_reel_model.dart';
import 'package:reelio/features/profile/data/models/profile_user_model.dart';
import 'package:reelio/features/profile/data/models/public_profile_user_model.dart';

abstract class ProfileRemoteDataSource {
  Stream<ProfileUserModel> observeCurrentProfile();

  Future<ProfileUserModel> getCurrentProfile();

  Future<PublicProfileUserModel> getProfileByUsername({
    required String username,
  });

  Future<List<ProfileReelModel>> getReelsByUserId({
    required String userId,
    int limit = 60,
  });

  Future<ProfileUserModel> updateProfile({
    required String displayName,
    required String bio,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<bool> toggleFollowUser({
    required String targetUserId,
    required bool currentlyFollowing,
  });
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  @override
  Stream<ProfileUserModel> observeCurrentProfile() async* {
    final user = _requireUser();
    final userRef = _usersCollection.doc(user.uid);
    final existingDoc = await userRef.get();

    if (!existingDoc.exists) {
      final seed = <String, dynamic>{
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'Reelio User',
        'displayNameLower': (user.displayName ?? 'Reelio User').toLowerCase(),
        'username': '',
        'photoUrl': user.photoURL,
        'bio': '',
        'reelsCount': 0,
        'followerCount': 0,
        'followingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await userRef.set(seed, SetOptions(merge: true));
      yield ProfileUserModel.fromFirestore(firebaseUser: user, data: seed);
    }

    yield* userRef.snapshots().map(
      (snapshot) => ProfileUserModel.fromFirestore(
        firebaseUser: _firebaseAuth.currentUser ?? user,
        data: snapshot.data() ?? <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ProfileUserModel> getCurrentProfile() async {
    final user = _requireUser();
    final userRef = _usersCollection.doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final seed = <String, dynamic>{
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'Reelio User',
        'displayNameLower': (user.displayName ?? 'Reelio User').toLowerCase(),
        'username': '',
        'photoUrl': user.photoURL,
        'bio': '',
        'reelsCount': 0,
        'followerCount': 0,
        'followingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await userRef.set(seed, SetOptions(merge: true));
      return ProfileUserModel.fromFirestore(firebaseUser: user, data: seed);
    }

    return ProfileUserModel.fromFirestore(
      firebaseUser: user,
      data: doc.data() ?? <String, dynamic>{},
    );
  }

  @override
  Future<PublicProfileUserModel> getProfileByUsername({
    required String username,
  }) async {
    final currentUser = _requireUser();
    final normalizedUsername = username
        .trim()
        .replaceFirst('@', '')
        .toLowerCase();

    final snapshot = await _usersCollection
        .where('username', isEqualTo: normalizedUsername)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Profile not found.',
      );
    }

    final userDoc = snapshot.docs.first;
    final isCurrentUser = userDoc.id == currentUser.uid;
    var isFollowing = false;

    if (!isCurrentUser) {
      final followingDoc = await _usersCollection
          .doc(currentUser.uid)
          .collection('following')
          .doc(userDoc.id)
          .get();
      isFollowing = followingDoc.exists;
    }

    return PublicProfileUserModel.fromFirestore(
      doc: userDoc,
      currentUserId: currentUser.uid,
      isFollowing: isFollowing,
    );
  }

  @override
  Future<List<ProfileReelModel>> getReelsByUserId({
    required String userId,
    int limit = 60,
  }) async {
    final snapshot = await _reelsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(ProfileReelModel.fromFirestore)
        .where((reel) => reel.videoUrl.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<ProfileUserModel> updateProfile({
    required String displayName,
    required String bio,
  }) async {
    final user = _requireUser();
    await user.updateDisplayName(displayName);

    final data = <String, dynamic>{
      'email': user.email ?? '',
      'displayName': displayName,
      'displayNameLower': displayName.toLowerCase(),
      'photoUrl': user.photoURL,
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final userRef = _usersCollection.doc(user.uid);
    await userRef.set(data, SetOptions(merge: true));

    final refreshedDoc = await userRef.get();
    return ProfileUserModel.fromFirestore(
      firebaseUser: _firebaseAuth.currentUser ?? user,
      data: refreshedDoc.data() ?? data,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    final userEmail = user.email;

    final hasPasswordProvider = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );

    if (!hasPasswordProvider || userEmail == null) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message:
            'Password change is only available for email/password accounts.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: userEmail,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Future<bool> toggleFollowUser({
    required String targetUserId,
    required bool currentlyFollowing,
  }) async {
    final currentUser = _requireUser();
    if (currentUser.uid == targetUserId) {
      return currentlyFollowing;
    }

    final shouldFollow = !currentlyFollowing;
    final currentUserRef = _usersCollection.doc(currentUser.uid);
    final targetUserRef = _usersCollection.doc(targetUserId);
    final followingRef = currentUserRef
        .collection('following')
        .doc(targetUserId);
    final followerRef = targetUserRef
        .collection('followers')
        .doc(currentUser.uid);

    final existing = await followingRef.get();
    if (shouldFollow == existing.exists) {
      return shouldFollow;
    }

    final batch = _firestore.batch();

    if (shouldFollow) {
      batch
        ..set(followingRef, {
          'uid': targetUserId,
          'createdAt': FieldValue.serverTimestamp(),
        })
        ..set(followerRef, {
          'uid': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
        })
        ..set(currentUserRef, {
          'followingCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        ..set(targetUserRef, {
          'followerCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    } else {
      batch
        ..delete(followingRef)
        ..delete(followerRef)
        ..set(currentUserRef, {
          'followingCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        ..set(targetUserRef, {
          'followerCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    }

    await batch.commit();
    return shouldFollow;
  }

  User _requireUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user found.',
      );
    }
    return user;
  }
}
