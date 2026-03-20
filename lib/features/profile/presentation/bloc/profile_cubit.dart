import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/usecases/get_current_profile_usecase.dart';
import 'package:reelio/features/profile/domain/usecases/observe_current_profile_usecase.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getCurrentProfileUseCase,
    this._observeCurrentProfileUseCase,
  ) : super(const ProfileState.initial());

  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final ObserveCurrentProfileUseCase _observeCurrentProfileUseCase;
  StreamSubscription<ProfileUser>? _profileSubscription;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    final result = await _getCurrentProfileUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (profile) {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            user: profile,
            clearError: true,
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
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
