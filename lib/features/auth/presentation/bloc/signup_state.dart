part of 'signup_cubit.dart';

enum SignupStatus { initial, submitting, success, error }

class SignupState extends Equatable {
  const SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.status = SignupStatus.initial,
    this.errorMessage,
  });
  final String name;
  final String email;
  final String password;
  final SignupStatus status;
  final String? errorMessage;

  SignupState copyWith({
    String? name,
    String? email,
    String? password,
    SignupStatus? status,
    String? errorMessage,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [name, email, password, status, errorMessage];
}
