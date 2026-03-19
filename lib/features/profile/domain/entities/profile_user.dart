import 'package:equatable/equatable.dart';

class ProfileUser extends Equatable {
  const ProfileUser({
    required this.uid,
    required this.email,
    required this.displayName,
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
  final String? photoUrl;
  final String bio;
  final int reelsCount;
  final int followerCount;
  final int followingCount;
  final bool canChangePassword;

  String get username {
    final source = displayName.trim().isNotEmpty
        ? displayName
        : email.split('@').first;
    final normalized = source.toLowerCase().replaceAll(
      RegExp('[^a-z0-9_]'),
      '',
    );
    return normalized.isEmpty ? 'user' : normalized;
  }

  ProfileUser copyWith({
    String? uid,
    String? email,
    String? displayName,
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
    photoUrl,
    bio,
    reelsCount,
    followerCount,
    followingCount,
    canChangePassword,
  ];
}
