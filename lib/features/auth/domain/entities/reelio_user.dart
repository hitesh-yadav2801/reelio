import 'package:equatable/equatable.dart';

/// Reelio application user entity.
class ReelioUser extends Equatable {
  const ReelioUser({
    required this.uid,
    required this.email,
    this.username = '',
    this.displayName,
    this.photoUrl,
    this.bio,
    this.followerCount = 0,
    this.followingCount = 0,
    this.createdAt,
    this.updatedAt,
  });
  final String uid;
  final String email;
  final String username;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasUsername => username.trim().isNotEmpty;

  /// Static constant for an unauthenticated user or empty state.
  static const empty = ReelioUser(uid: '', email: '');

  @override
  List<Object?> get props => [
    uid,
    email,
    username,
    displayName,
    photoUrl,
    bio,
    followerCount,
    followingCount,
    createdAt,
    updatedAt,
  ];
}
