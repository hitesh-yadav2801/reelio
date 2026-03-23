import 'package:equatable/equatable.dart';
import 'package:reelio/features/comments/domain/entities/comment.dart';

class CommentsPage extends Equatable {
  const CommentsPage({
    required this.comments,
    required this.hasMore,
    this.lastCommentId,
  });

  final List<Comment> comments;
  final bool hasMore;
  final String? lastCommentId;

  @override
  List<Object?> get props => [comments, hasMore, lastCommentId];
}
