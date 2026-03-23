import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    this.userAvatarUrl,
  });

  final String id;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    userAvatarUrl,
    text,
    createdAt,
  ];
}
