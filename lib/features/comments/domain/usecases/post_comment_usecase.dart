import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/comments/domain/entities/comment.dart';
import 'package:reelio/features/comments/domain/repositories/comment_repository.dart';

class PostCommentParams extends Equatable {
  const PostCommentParams({required this.reelId, required this.text});

  final String reelId;
  final String text;

  @override
  List<Object?> get props => [reelId, text];
}

@lazySingleton
class PostCommentUseCase
    extends UseCase<FutureEither<Comment>, PostCommentParams> {
  PostCommentUseCase(this._commentRepository);

  final CommentRepository _commentRepository;

  @override
  FutureEither<Comment> call(PostCommentParams params) {
    return _commentRepository.postComment(
      reelId: params.reelId,
      text: params.text,
    );
  }
}
