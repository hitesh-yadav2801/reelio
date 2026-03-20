import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmailParams extends Equatable {
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String email;
  final String password;
  final String fullName;

  @override
  List<Object?> get props => [email, password, fullName];
}

@lazySingleton
class SignUpWithEmailUseCase
    extends UseCase<FutureEitherVoid, SignUpWithEmailParams> {
  SignUpWithEmailUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  FutureEitherVoid call(SignUpWithEmailParams params) {
    return _authRepository.signUpWithEmail(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}
