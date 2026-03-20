import 'package:equatable/equatable.dart';

class ProfileUser extends Equatable {
  const ProfileUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username = '',
    this.photoUrl,
    this.bio = '',
    this.reelsCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.canChangePassword = false,
  });

  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String? photoUrl;
  final String bio;
  final int reelsCount;
  final int followerCount;
  final int followingCount;
  final bool canChangePassword;

  bool get hasUsername => username.trim().isNotEmpty;

  ProfileUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? photoUrl,
    String? bio,
    int? reelsCount,
    int? followerCount,
    int? followingCount,
    bool? canChangePassword,
  }) {
    return ProfileUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      reelsCount: reelsCount ?? this.reelsCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      canChangePassword: canChangePassword ?? this.canChangePassword,
    );
  }

  static const empty = ProfileUser(uid: '', email: '', displayName: '');

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    username,
    photoUrl,
    bio,
    reelsCount,
    followerCount,
    followingCount,
    canChangePassword,
  ];
}
