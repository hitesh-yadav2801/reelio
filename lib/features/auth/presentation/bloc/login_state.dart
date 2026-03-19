part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  submittingCredentials,
  submittingGoogle,
  success,
  error,
}

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
  });
  final String email;
  final String password;
  final LoginStatus status;
  final String? errorMessage;

  bool get isSubmitting {
    return status == LoginStatus.submittingCredentials ||
        status == LoginStatus.submittingGoogle;
  }

  bool get isSubmittingCredentials =>
      status == LoginStatus.submittingCredentials;

  bool get isSubmittingGoogle => status == LoginStatus.submittingGoogle;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage];
}
