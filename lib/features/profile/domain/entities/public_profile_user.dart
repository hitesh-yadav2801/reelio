import 'package:equatable/equatable.dart';

class PublicProfileUser extends Equatable {
  const PublicProfileUser({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.reelsCount,
    required this.followerCount,
    required this.followingCount,
    required this.isCurrentUser,
    this.photoUrl,
    this.bio = '',
    this.isFollowing = false,
  });

  final String uid;
  final String displayName;
  final String username;
  final String? photoUrl;
  final String bio;
  final int reelsCount;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;
  final bool isCurrentUser;

  PublicProfileUser copyWith({
    String? uid,
    String? displayName,
    String? username,
    String? photoUrl,
    String? bio,
    int? reelsCount,
    int? followerCount,
    int? followingCount,
    bool? isFollowing,
    bool? isCurrentUser,
  }) {
    return PublicProfileUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      reelsCount: reelsCount ?? this.reelsCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    displayName,
    username,
    photoUrl,
    bio,
    reelsCount,
    followerCount,
    followingCount,
    isFollowing,
    isCurrentUser,
  ];
}
