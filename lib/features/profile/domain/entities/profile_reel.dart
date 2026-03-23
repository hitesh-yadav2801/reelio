import 'package:equatable/equatable.dart';

class ProfileReel extends Equatable {
  const ProfileReel({
    required this.id,
    required this.videoUrl,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    this.thumbnailUrl,
  });

  final String id;
  final String videoUrl;
  final String? thumbnailUrl;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    videoUrl,
    thumbnailUrl,
    caption,
    likesCount,
    commentsCount,
    createdAt,
  ];
}
