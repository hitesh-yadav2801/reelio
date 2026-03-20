import 'package:equatable/equatable.dart';

class Reel extends Equatable {
  const Reel({
    required this.id,
    required this.userId,
    required this.username,
    required this.videoUrl,
    required this.createdAt,
    this.userAvatarUrl,
    this.thumbnailUrl,
    this.caption = '',
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  final String id;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String videoUrl;
  final String? thumbnailUrl;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    userAvatarUrl,
    videoUrl,
    thumbnailUrl,
    caption,
    likesCount,
    commentsCount,
    createdAt,
  ];
}
