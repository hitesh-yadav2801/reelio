import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/likes/domain/usecases/get_like_status_usecase.dart';
import 'package:reelio/features/likes/domain/usecases/toggle_like_usecase.dart';

part 'like_state.dart';

@injectable
class LikeCubit extends Cubit<LikeState> {
  LikeCubit(this._getLikeStatusUseCase, this._toggleLikeUseCase)
    : super(const LikeState.initial());

  final GetLikeStatusUseCase _getLikeStatusUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;

  bool isLiked(String reelId) => state.likedByReel[reelId] ?? false;

  bool hasStatus(String reelId) => state.likedByReel.containsKey(reelId);

  Future<void> loadLikeStatus(String reelId) async {
    if (reelId.trim().isEmpty ||
        state.loadingReelIds.contains(reelId) ||
        hasStatus(reelId)) {
      return;
    }

    final nextLoading = {...state.loadingReelIds, reelId};
    emit(state.copyWith(loadingReelIds: nextLoading, clearActionError: true));

    final result = await _getLikeStatusUseCase(
      GetLikeStatusParams(reelId: reelId),
    );

    final finalLoading = {...state.loadingReelIds}..remove(reelId);

    result.fold(
      (_) {
        // Background like-status prefetch should not surface user-facing
        // errors (for example, one snackbar per reel when opening offline).
        // Store a safe default so we don't keep retrying per item rebuild.
        final nextMap = {...state.likedByReel}
          ..putIfAbsent(reelId, () => false);

        emit(
          state.copyWith(
            likedByReel: nextMap,
            loadingReelIds: finalLoading,
            clearActionError: true,
          ),
        );
      },
      (isLiked) {
        final nextMap = {...state.likedByReel, reelId: isLiked};
        emit(
          state.copyWith(likedByReel: nextMap, loadingReelIds: finalLoading),
        );
      },
    );
  }

  void setOptimisticLike(String reelId, {required bool isLiked}) {
    final nextMap = {...state.likedByReel, reelId: isLiked};
    emit(state.copyWith(likedByReel: nextMap, clearActionError: true));
  }

  Future<bool> commitToggle({
    required String reelId,
    required bool currentlyLiked,
  }) async {
    final result = await _toggleLikeUseCase(
      ToggleLikeParams(reelId: reelId, currentlyLiked: currentlyLiked),
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(actionErrorMessage: failure.message));
        return false;
      },
      (isLiked) {
        final nextMap = {...state.likedByReel, reelId: isLiked};
        emit(state.copyWith(likedByReel: nextMap, clearActionError: true));
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
