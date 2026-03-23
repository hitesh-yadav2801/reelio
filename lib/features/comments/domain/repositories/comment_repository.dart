import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/comments/domain/entities/comment.dart';
import 'package:reelio/features/comments/domain/entities/comments_page.dart';

abstract class CommentRepository {
  FutureEither<CommentsPage> getCommentsPage({
    required String reelId,
    String? lastCommentId,
    int limit = 10,
  });

  FutureEither<Comment> postComment({
    required String reelId,
    required String text,
  });
}
