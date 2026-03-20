part of 'signup_cubit.dart';

enum SignupStatus { initial, submitting, success, error }

class SignupState extends Equatable {
  const SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = SignupStatus.initial,
    this.errorMessage,
  });
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final SignupStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == SignupStatus.submitting;

  bool get canSubmit {
    return name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        password.length >= 6 &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword &&
        !isSubmitting;
  }

  SignupState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    SignupStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    confirmPassword,
    status,
    errorMessage,
  ];

  @override
  bool get stringify => false;
}
