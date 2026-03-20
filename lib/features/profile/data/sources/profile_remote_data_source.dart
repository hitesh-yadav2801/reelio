import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/profile/data/models/profile_user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileUserModel> getCurrentProfile();

  Future<ProfileUserModel> updateProfile({
    required String displayName,
    required String bio,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<ProfileUserModel> getCurrentProfile() async {
    final user = _requireUser();
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final seed = <String, dynamic>{
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'Reelio User',
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
  Future<ProfileUserModel> updateProfile({
    required String displayName,
    required String bio,
  }) async {
    final user = _requireUser();
    await user.updateDisplayName(displayName);

    final data = <String, dynamic>{
      'email': user.email ?? '',
      'displayName': displayName,
      'photoUrl': user.photoURL,
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final userRef = _firestore.collection('users').doc(user.uid);
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
