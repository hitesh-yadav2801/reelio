import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

part 'signup_state.dart';

@injectable
class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._authRepository) : super(const SignupState());
  final AuthRepository _authRepository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: SignupStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: SignupStatus.initial));
  }

  void nameChanged(String value) {
    emit(state.copyWith(name: value, status: SignupStatus.initial));
  }

  Future<void> signUp() async {
    if (state.email.isEmpty || state.password.isEmpty || state.name.isEmpty) {
      return;
    }

    emit(state.copyWith(status: SignupStatus.submitting));

    final result = await _authRepository.signUpWithEmail(
      email: state.email,
      password: state.password,
      fullName: state.name,
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
