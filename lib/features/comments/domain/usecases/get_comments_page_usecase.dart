import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/comments/domain/entities/comments_page.dart';
import 'package:reelio/features/comments/domain/repositories/comment_repository.dart';

class GetCommentsPageParams extends Equatable {
  const GetCommentsPageParams({
    required this.reelId,
    this.lastCommentId,
    this.limit = 10,
  });

  final String reelId;
  final String? lastCommentId;
  final int limit;

  @override
  List<Object?> get props => [reelId, lastCommentId, limit];
}

@lazySingleton
class GetCommentsPageUseCase
    extends UseCase<FutureEither<CommentsPage>, GetCommentsPageParams> {
  GetCommentsPageUseCase(this._commentRepository);

  final CommentRepository _commentRepository;

  @override
  FutureEither<CommentsPage> call(GetCommentsPageParams params) {
    return _commentRepository.getCommentsPage(
      reelId: params.reelId,
      lastCommentId: params.lastCommentId,
      limit: params.limit,
    );
  }
}
