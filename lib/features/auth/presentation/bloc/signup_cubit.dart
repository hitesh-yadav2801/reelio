import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

part 'signup_state.dart';

@injectable
class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._signUpWithEmailUseCase) : super(const SignupState());

  final SignUpWithEmailUseCase _signUpWithEmailUseCase;

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        status: SignupStatus.initial,
        clearError: true,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        status: SignupStatus.initial,
        clearError: true,
      ),
    );
  }

  void confirmPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmPassword: value,
        status: SignupStatus.initial,
        clearError: true,
      ),
    );
  }

  void nameChanged(String value) {
    emit(
      state.copyWith(
        name: value,
        status: SignupStatus.initial,
        clearError: true,
      ),
    );
  }

  Future<void> signUp() async {
    if (!state.canSubmit) {
      return;
    }

    emit(state.copyWith(status: SignupStatus.submitting, clearError: true));

    final result = await _signUpWithEmailUseCase(
      SignUpWithEmailParams(
        email: state.email,
        password: state.password,
        fullName: state.name,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SignupStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: SignupStatus.success)),
    );
  }
}
