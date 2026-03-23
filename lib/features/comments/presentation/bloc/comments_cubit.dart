import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/comments/domain/entities/comment.dart';
import 'package:reelio/features/comments/domain/usecases/get_comments_page_usecase.dart';
import 'package:reelio/features/comments/domain/usecases/post_comment_usecase.dart';

part 'comments_state.dart';

@injectable
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._getCommentsPageUseCase, this._postCommentUseCase)
    : super(const CommentsState.initial());

  final GetCommentsPageUseCase _getCommentsPageUseCase;
  final PostCommentUseCase _postCommentUseCase;

  static const int _pageSize = 10;

  Future<void> loadInitial(String reelId) async {
    if (reelId.trim().isEmpty || state.status == CommentsStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        status: CommentsStatus.loading,
        reelId: reelId,
        comments: const [],
        hasMore: true,
        lastCommentId: null,
        clearError: true,
        clearActionError: true,
      ),
    );

    final result = await _getCommentsPageUseCase(
      GetCommentsPageParams(reelId: reelId, limit: _pageSize),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CommentsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: CommentsStatus.loaded,
          comments: page.comments,
          hasMore: page.hasMore,
          lastCommentId: page.lastCommentId,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.status != CommentsStatus.loaded ||
        state.reelId == null ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearActionError: true));

    final result = await _getCommentsPageUseCase(
      GetCommentsPageParams(
        reelId: state.reelId!,
        lastCommentId: state.lastCommentId,
        limit: _pageSize,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          actionErrorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          isLoadingMore: false,
          comments: [...state.comments, ...page.comments],
          hasMore: page.hasMore,
          lastCommentId: page.lastCommentId,
          clearActionError: true,
        ),
      ),
    );
  }

  Future<bool> postComment(String text) async {
    final reelId = state.reelId;
    final trimmed = text.trim();

    if (reelId == null || trimmed.isEmpty || state.isPosting) {
      return false;
    }

    if (trimmed.length > 220) {
      emit(
        state.copyWith(
          actionErrorMessage: 'Comment should be 220 characters or fewer.',
        ),
      );
      return false;
    }

    emit(state.copyWith(isPosting: true, clearActionError: true));

    final result = await _postCommentUseCase(
      PostCommentParams(reelId: reelId, text: trimmed),
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(isPosting: false, actionErrorMessage: failure.message),
        );
        return false;
      },
      (comment) {
        emit(
          state.copyWith(
            status: CommentsStatus.loaded,
            isPosting: false,
            comments: [comment, ...state.comments],
            clearActionError: true,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  void clearActionError() {
    if (state.actionErrorMessage == null) {
      return;
    }

    emit(state.copyWith(clearActionError: true));
  }
}
