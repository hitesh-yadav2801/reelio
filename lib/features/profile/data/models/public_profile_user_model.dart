import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelio/features/profile/domain/entities/public_profile_user.dart';

class PublicProfileUserModel extends PublicProfileUser {
  const PublicProfileUserModel({
    required super.uid,
    required super.displayName,
    required super.username,
    required super.reelsCount,
    required super.followerCount,
    required super.followingCount,
    required super.isCurrentUser,
    super.photoUrl,
    super.bio,
    super.isFollowing,
  });

  factory PublicProfileUserModel.fromFirestore({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required String currentUserId,
    required bool isFollowing,
  }) {
    final data = doc.data() ?? <String, dynamic>{};

    return PublicProfileUserModel(
      uid: doc.id,
      displayName: (data['displayName'] as String? ?? 'Reelio User').trim(),
      username: (data['username'] as String? ?? '').trim(),
      photoUrl: _nullableText(data['photoUrl'] as String?),
      bio: (data['bio'] as String? ?? '').trim(),
      reelsCount: _toInt(data['reelsCount']),
      followerCount: _toInt(data['followerCount']),
      followingCount: _toInt(data['followingCount']),
      isFollowing: isFollowing,
      isCurrentUser: doc.id == currentUserId,
    );
  }

  static int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String? _nullableText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
