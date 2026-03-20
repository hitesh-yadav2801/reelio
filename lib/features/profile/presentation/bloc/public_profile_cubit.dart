import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/profile/domain/entities/profile_reel.dart';
import 'package:reelio/features/profile/domain/entities/public_profile_user.dart';
import 'package:reelio/features/profile/domain/usecases/get_profile_reels_usecase.dart';
import 'package:reelio/features/profile/domain/usecases/get_public_profile_usecase.dart';
import 'package:reelio/features/profile/domain/usecases/toggle_public_profile_follow_usecase.dart';

part 'public_profile_state.dart';

@injectable
class PublicProfileCubit extends Cubit<PublicProfileState> {
  PublicProfileCubit(
    this._getPublicProfileUseCase,
    this._getProfileReelsUseCase,
    this._togglePublicProfileFollowUseCase,
  ) : super(const PublicProfileState.initial());

  final GetPublicProfileUseCase _getPublicProfileUseCase;
  final GetProfileReelsUseCase _getProfileReelsUseCase;
  final TogglePublicProfileFollowUseCase _togglePublicProfileFollowUseCase;

  Future<void> loadByUsername(String username) async {
    final normalized = _normalizeUsername(username);
    if (normalized.isEmpty) {
      emit(
        state.copyWith(
          status: PublicProfileStatus.error,
          errorMessage: 'Invalid username provided.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PublicProfileStatus.loading,
        username: normalized,
        clearError: true,
        clearActionError: true,
      ),
    );

    final profileResult = await _getPublicProfileUseCase(
      GetPublicProfileParams(username: normalized),
    );

    await profileResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: PublicProfileStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (profile) async {
        final reelsResult = await _getProfileReelsUseCase(
          GetProfileReelsParams(userId: profile.uid),
        );

        reelsResult.fold(
          (failure) => emit(
            state.copyWith(
              status: PublicProfileStatus.loaded,
              user: profile,
              reels: const [],
              actionErrorMessage: failure.message,
              clearError: true,
            ),
          ),
          (reels) => emit(
            state.copyWith(
              status: PublicProfileStatus.loaded,
              user: profile,
              reels: reels,
              clearError: true,
              clearActionError: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    if (state.username.isEmpty) {
      return;
    }
    await loadByUsername(state.username);
  }

  Future<void> toggleFollow() async {
    final user = state.user;
    if (user == null || user.isCurrentUser || state.isFollowUpdating) {
      return;
    }

    final previous = user;
    final nextFollowValue = !user.isFollowing;
    final nextFollowerCount = user.followerCount + (nextFollowValue ? 1 : -1);

    emit(
      state.copyWith(
        user: user.copyWith(
          isFollowing: nextFollowValue,
          followerCount: nextFollowerCount < 0 ? 0 : nextFollowerCount,
        ),
        isFollowUpdating: true,
        clearActionError: true,
      ),
    );

    final result = await _togglePublicProfileFollowUseCase(
      TogglePublicProfileFollowParams(
        targetUserId: user.uid,
        currentlyFollowing: previous.isFollowing,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          user: previous,
          isFollowUpdating: false,
          actionErrorMessage: failure.message,
        ),
      ),
      (isFollowing) {
        final followerCount = previous.followerCount + (isFollowing ? 1 : -1);
        emit(
          state.copyWith(
            user: previous.copyWith(
              isFollowing: isFollowing,
              followerCount: followerCount < 0 ? 0 : followerCount,
            ),
            isFollowUpdating: false,
            clearActionError: true,
          ),
        );
      },
    );
  }

  void clearActionError() {
    if (state.actionErrorMessage == null) {
      return;
    }

    emit(state.copyWith(clearActionError: true));
  }

  String _normalizeUsername(String value) {
    return value.trim().replaceFirst('@', '').toLowerCase();
  }
}
