import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/search/domain/entities/search_user.dart';
import 'package:reelio/features/search/domain/usecases/search_users_usecase.dart';
import 'package:reelio/features/search/domain/usecases/toggle_follow_usecase.dart';

part 'search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchUsersUseCase, this._toggleFollowUseCase)
    : super(const SearchState());

  final SearchUsersUseCase _searchUsersUseCase;
  final ToggleFollowUseCase _toggleFollowUseCase;
  Timer? _searchDebounce;

  static const Duration _debounceDuration = Duration(milliseconds: 400);

  void queryChanged(String value) {
    final nextQuery = value.trim();
    _searchDebounce?.cancel();

    if (nextQuery.isEmpty) {
      emit(
        state.copyWith(
          query: '',
          status: SearchStatus.initial,
          results: const [],
          clearError: true,
          clearActionError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        query: nextQuery,
        status: SearchStatus.loading,
        clearError: true,
      ),
    );

    _searchDebounce = Timer(_debounceDuration, () => _performSearch(nextQuery));
  }

  Future<void> _performSearch(String query) async {
    final result = await _searchUsersUseCase(SearchUsersParams(query: query));

    if (isClosed || state.query != query) {
      return;
    }

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (users) {
        if (users.isEmpty) {
          emit(state.copyWith(status: SearchStatus.empty, results: const []));
          return;
        }

        emit(state.copyWith(status: SearchStatus.loaded, results: users));
      },
    );
  }

  Future<void> toggleFollow(SearchUser user) async {
    if (user.isUpdating) {
      return;
    }

    final previousState = user.isFollowing;
    final optimisticState = !previousState;

    _updateUser(
      user.uid,
      isFollowing: optimisticState,
      isUpdating: true,
      clearActionError: true,
    );

    final result = await _toggleFollowUseCase(
      ToggleFollowParams(
        targetUserId: user.uid,
        currentlyFollowing: previousState,
      ),
    );

    if (isClosed) {
      return;
    }

    result.fold(
      (failure) => _updateUser(
        user.uid,
        isFollowing: previousState,
        isUpdating: false,
        actionErrorMessage: failure.message,
      ),
      (isFollowing) => _updateUser(
        user.uid,
        isFollowing: isFollowing,
        isUpdating: false,
        clearActionError: true,
      ),
    );
  }

  void clearActionError() {
    if (state.actionErrorMessage == null) {
      return;
    }

    emit(state.copyWith(clearActionError: true));
  }

  void _updateUser(
    String uid, {
    required bool isFollowing,
    required bool isUpdating,
    String? actionErrorMessage,
    bool clearActionError = false,
  }) {
    final updated = state.results
        .map(
          (result) => result.uid == uid
              ? result.copyWith(
                  isFollowing: isFollowing,
                  isUpdating: isUpdating,
                )
              : result,
        )
        .toList(growable: false);

    emit(
      state.copyWith(
        results: updated,
        actionErrorMessage: actionErrorMessage,
        clearActionError: clearActionError,
      ),
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
