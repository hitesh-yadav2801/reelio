import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/comments/data/sources/comment_remote_data_source.dart';
import 'package:reelio/features/comments/domain/entities/comment.dart';
import 'package:reelio/features/comments/domain/entities/comments_page.dart';
import 'package:reelio/features/comments/domain/repositories/comment_repository.dart';

@LazySingleton(as: CommentRepository)
class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._remoteDataSource);

  final CommentRemoteDataSource _remoteDataSource;

  @override
  FutureEither<CommentsPage> getCommentsPage({
    required String reelId,
    String? lastCommentId,
    int limit = 10,
  }) async {
    try {
      final page = await _remoteDataSource.fetchCommentsPage(
        reelId: reelId,
        lastCommentId: lastCommentId,
        limit: limit,
      );
      return right(page);
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Unable to load comments.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEither<Comment> postComment({
    required String reelId,
    required String text,
  }) async {
    try {
      final comment = await _remoteDataSource.postComment(
        reelId: reelId,
        text: text,
      );
      return right(comment);
    } on FirebaseAuthException catch (error) {
      return left(AuthFailure(error.message ?? 'Authentication required.'));
    } on FirebaseException catch (error) {
      return left(FirestoreFailure(error.message ?? 'Unable to post comment.'));
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}
