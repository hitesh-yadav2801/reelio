import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';
import 'package:reelio/features/feed/domain/usecases/get_initial_reels_usecase.dart';
import 'package:reelio/features/feed/domain/usecases/get_more_reels_usecase.dart';

part 'feed_state.dart';

@injectable
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._getInitialReelsUseCase, this._getMoreReelsUseCase)
    : super(const FeedState.initial());

  final GetInitialReelsUseCase _getInitialReelsUseCase;
  final GetMoreReelsUseCase _getMoreReelsUseCase;

  bool _isInitialInFlight = false;
  bool _isLoadMoreInFlight = false;

  Future<void> fetchInitial({int limit = 10}) async {
    if (_isInitialInFlight) {
      return;
    }

    _isInitialInFlight = true;
    emit(state.copyWith(status: FeedStatus.loading, clearError: true));

    final result = await _getInitialReelsUseCase(
      GetInitialReelsParams(limit: limit),
    );

    _isInitialInFlight = false;

    result.fold(
      (failure) => emit(
        state.copyWith(status: FeedStatus.error, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          status: FeedStatus.loaded,
          reels: page.reels,
          hasMore: page.hasMore,
          lastReelId: page.lastReelId,
          currentIndex: 0,
          clearError: true,
          clearActionError: true,
        ),
      ),
    );
  }

  Future<void> refresh({int limit = 10}) async {
    if (_isInitialInFlight || state.status == FeedStatus.refreshing) {
      return;
    }

    emit(state.copyWith(status: FeedStatus.refreshing, clearError: true));

    final result = await _getInitialReelsUseCase(
      GetInitialReelsParams(limit: limit),
    );

    result.fold(
      (failure) {
        if (state.reels.isNotEmpty) {
          emit(
            state.copyWith(
              status: FeedStatus.loaded,
              actionErrorMessage: failure.message,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: FeedStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (page) => emit(
        state.copyWith(
          status: FeedStatus.loaded,
          reels: page.reels,
          hasMore: page.hasMore,
          lastReelId: page.lastReelId,
          currentIndex: 0,
          clearError: true,
          clearActionError: true,
        ),
      ),
    );
  }

  Future<void> loadMore({int limit = 10}) async {
    if (_isLoadMoreInFlight ||
        !state.hasMore ||
        state.lastReelId == null ||
        state.status == FeedStatus.loading ||
        state.status == FeedStatus.refreshing) {
      return;
    }

    _isLoadMoreInFlight = true;
    emit(state.copyWith(status: FeedStatus.loadingMore, clearError: true));

    final result = await _getMoreReelsUseCase(
      GetMoreReelsParams(lastReelId: state.lastReelId!, limit: limit),
    );

    _isLoadMoreInFlight = false;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FeedStatus.loaded,
          actionErrorMessage: failure.message,
        ),
      ),
      (page) {
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            reels: [...state.reels, ...page.reels],
            hasMore: page.hasMore,
            lastReelId: page.lastReelId,
            clearError: true,
          ),
        );
      },
    );
  }

  void setCurrentIndex(int index) {
    if (index < 0 ||
        index >= state.reels.length ||
        index == state.currentIndex) {
      return;
    }

    emit(state.copyWith(currentIndex: index));
  }

  void clearActionError() {
    if (state.actionErrorMessage == null) {
      return;
    }

    emit(state.copyWith(clearActionError: true));
  }
}
