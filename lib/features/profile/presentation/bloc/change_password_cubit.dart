import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/profile/domain/usecases/change_password_usecase.dart';

part 'change_password_state.dart';

@injectable
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePasswordUseCase)
    : super(const ChangePasswordState());

  final ChangePasswordUseCase _changePasswordUseCase;

  void currentPasswordChanged(String value) {
    emit(
      state.copyWith(
        currentPassword: value,
        status: ChangePasswordStatus.editing,
        clearMessage: true,
      ),
    );
  }

  void newPasswordChanged(String value) {
    emit(
      state.copyWith(
        newPassword: value,
        status: ChangePasswordStatus.editing,
        clearMessage: true,
      ),
    );
  }

  void confirmPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmPassword: value,
        status: ChangePasswordStatus.editing,
        clearMessage: true,
      ),
    );
  }

  Future<void> submit() async {
    final validationMessage = _validate();
    if (validationMessage != null) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.error,
          message: validationMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ChangePasswordStatus.submitting,
        clearMessage: true,
      ),
    );

    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: state.currentPassword,
        newPassword: state.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ChangePasswordStatus.error,
          message: failure.message,
        ),
      ),
      (_) => emit(
        const ChangePasswordState(
          status: ChangePasswordStatus.success,
          message: 'Password updated successfully.',
        ),
      ),
    );
  }

  String? _validate() {
    if (state.currentPassword.isEmpty ||
        state.newPassword.isEmpty ||
        state.confirmPassword.isEmpty) {
      return 'All fields are required.';
    }

    if (state.newPassword.length < 8) {
      return 'New password must be at least 8 characters.';
    }

    if (state.newPassword != state.confirmPassword) {
      return 'New password and confirm password do not match.';
    }

    if (state.currentPassword == state.newPassword) {
      return 'New password must be different from current password.';
    }

    return null;
  }
}
