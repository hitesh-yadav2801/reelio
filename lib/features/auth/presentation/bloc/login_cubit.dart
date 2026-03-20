import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:reelio/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signInWithEmailUseCase, this._signInWithGoogleUseCase)
    : super(const LoginState());

  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        status: LoginStatus.initial,
        clearError: true,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        status: LoginStatus.initial,
        clearError: true,
      ),
    );
  }

  Future<void> logInWithCredentials() async {
    if (state.email.isEmpty || state.password.isEmpty || state.isSubmitting) {
      return;
    }

    emit(
      state.copyWith(
        status: LoginStatus.submittingCredentials,
        clearError: true,
      ),
    );

    final result = await _signInWithEmailUseCase(
      SignInWithEmailParams(email: state.email, password: state.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LoginStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }

  Future<void> logInWithGoogle() async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(status: LoginStatus.submittingGoogle, clearError: true),
    );

    final result = await _signInWithGoogleUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LoginStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }
}
