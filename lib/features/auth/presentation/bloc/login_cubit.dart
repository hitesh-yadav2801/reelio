import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());
  final AuthRepository _authRepository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  Future<void> logInWithCredentials() async {
    if (state.email.isEmpty || state.password.isEmpty) return;

    emit(state.copyWith(status: LoginStatus.submitting));

    final result = await _authRepository.signInWithEmail(
      email: state.email,
      password: state.password,
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
    emit(state.copyWith(status: LoginStatus.submitting));

    final result = await _authRepository.signInWithGoogle();

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
