import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/validation/username_validator.dart';
import 'package:reelio/features/auth/domain/usecases/check_username_availability_usecase.dart';
import 'package:reelio/features/auth/domain/usecases/set_username_usecase.dart';
import 'package:reelio/features/auth/presentation/models/username_check_status.dart';

part 'username_setup_state.dart';

enum UsernameSetupStatus { initial, submitting, success, error }

@injectable
class UsernameSetupCubit extends Cubit<UsernameSetupState> {
  UsernameSetupCubit(this._checkUsernameUseCase, this._setUsernameUseCase)
    : super(const UsernameSetupState());

  final CheckUsernameAvailabilityUseCase _checkUsernameUseCase;
  final SetUsernameUseCase _setUsernameUseCase;
  Timer? _usernameDebounce;

  static const Duration _usernameCheckDelay = Duration(milliseconds: 350);

  void usernameChanged(String value) {
    final normalizedUsername = UsernameValidator.normalize(value);
    _usernameDebounce?.cancel();

    if (normalizedUsername.isEmpty) {
      emit(
        state.copyWith(
          username: normalizedUsername,
          usernameStatus: UsernameCheckStatus.initial,
          status: UsernameSetupStatus.initial,
          clearError: true,
          clearUsernameMessage: true,
        ),
      );
      return;
    }

    final validationError = UsernameValidator.validationError(
      normalizedUsername,
    );

    if (validationError != null) {
      emit(
        state.copyWith(
          username: normalizedUsername,
          usernameStatus: UsernameCheckStatus.invalid,
          usernameMessage: validationError,
          status: UsernameSetupStatus.initial,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        username: normalizedUsername,
        usernameStatus: UsernameCheckStatus.checking,
        status: UsernameSetupStatus.initial,
        clearError: true,
        clearUsernameMessage: true,
      ),
    );

    _usernameDebounce = Timer(_usernameCheckDelay, () async {
      final result = await _checkUsernameUseCase(
        CheckUsernameAvailabilityParams(username: normalizedUsername),
      );

      if (isClosed || state.username != normalizedUsername) {
        return;
      }

      result.fold(
        (_) => emit(
          state.copyWith(
            usernameStatus: UsernameCheckStatus.error,
            usernameMessage:
                'Unable to verify username right now. Please try again.',
          ),
        ),
        (isAvailable) => emit(
          state.copyWith(
            usernameStatus: isAvailable
                ? UsernameCheckStatus.available
                : UsernameCheckStatus.taken,
            usernameMessage: isAvailable ? null : 'Username is already taken.',
            clearUsernameMessage: isAvailable,
          ),
        ),
      );
    });
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      return;
    }

    emit(
      state.copyWith(status: UsernameSetupStatus.submitting, clearError: true),
    );

    final result = await _setUsernameUseCase(
      SetUsernameParams(username: state.username),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UsernameSetupStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: UsernameSetupStatus.success)),
    );
  }

  @override
  Future<void> close() {
    _usernameDebounce?.cancel();
    return super.close();
  }
}
