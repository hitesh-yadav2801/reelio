import 'package:firebase_auth/firebase_auth.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';

class ProfileUserModel extends ProfileUser {
  const ProfileUserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.bio,
    super.reelsCount,
    super.followerCount,
    super.followingCount,
    super.canChangePassword,
  });

  factory ProfileUserModel.fromFirestore({
    required User firebaseUser,
    required Map<String, dynamic> data,
  }) {
    final hasPasswordProvider = firebaseUser.providerData.any(
      (provider) => provider.providerId == 'password',
    );

    return ProfileUserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? (data['email'] as String? ?? ''),
      displayName:
          data['displayName'] as String? ??
          firebaseUser.displayName ??
          'Reelio User',
      photoUrl: data['photoUrl'] as String? ?? firebaseUser.photoURL,
      bio: data['bio'] as String? ?? '',
      reelsCount: data['reelsCount'] as int? ?? 0,
      followerCount: data['followerCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      canChangePassword: hasPasswordProvider,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'reelsCount': reelsCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
    };
  }
}
