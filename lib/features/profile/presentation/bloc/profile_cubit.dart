import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/profile/domain/entities/profile_reel.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/usecases/get_current_profile_usecase.dart';
import 'package:reelio/features/profile/domain/usecases/get_profile_reels_usecase.dart';
import 'package:reelio/features/profile/domain/usecases/observe_current_profile_usecase.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getCurrentProfileUseCase,
    this._getProfileReelsUseCase,
    this._observeCurrentProfileUseCase,
  ) : super(const ProfileState.initial());

  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final GetProfileReelsUseCase _getProfileReelsUseCase;
  final ObserveCurrentProfileUseCase _observeCurrentProfileUseCase;
  StreamSubscription<ProfileUser>? _profileSubscription;

  Future<void> loadProfile() async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        clearError: true,
        clearActionError: true,
      ),
    );
    final result = await _getCurrentProfileUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (profile) async {
        final reelsResult = await _getProfileReelsUseCase(
          GetProfileReelsParams(userId: profile.uid),
        );

        reelsResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ProfileStatus.loaded,
              user: profile,
              reels: const [],
              actionErrorMessage: failure.message,
              clearError: true,
            ),
          ),
          (reels) => emit(
            state.copyWith(
              status: ProfileStatus.loaded,
              user: profile,
              reels: reels,
              clearError: true,
              clearActionError: true,
            ),
          ),
        );

        _subscribeToProfile();
      },
    );
  }

  void _subscribeToProfile() {
    _profileSubscription?.cancel();
    _profileSubscription = _observeCurrentProfileUseCase(const NoParams())
        .listen(
          (profile) {
            emit(
              state.copyWith(
                status: ProfileStatus.loaded,
                user: profile,
                reels: state.reels,
                clearError: true,
              ),
            );
          },
          onError: (_) {
            emit(
              state.copyWith(
                status: ProfileStatus.error,
                errorMessage: 'Unable to load profile.',
              ),
            );
          },
        );
  }

  void profileUpdated(ProfileUser user) {
    emit(
      state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
        reels: state.reels,
        clearError: true,
      ),
    );
  }

  void clearActionError() {
    if (state.actionErrorMessage == null) {
      return;
    }

    emit(state.copyWith(clearActionError: true));
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
