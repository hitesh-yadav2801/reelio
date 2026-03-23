import 'package:reelio/features/comments/domain/entities/comments_page.dart';

class CommentsPageModel extends CommentsPage {
  const CommentsPageModel({
    required super.comments,
    required super.hasMore,
    super.lastCommentId,
  });
}
