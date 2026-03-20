import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailParams extends Equatable {
  const SignInWithEmailParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

@lazySingleton
class SignInWithEmailUseCase
    extends UseCase<FutureEither<ReelioUser>, SignInWithEmailParams> {
  SignInWithEmailUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  FutureEither<ReelioUser> call(SignInWithEmailParams params) {
    return _authRepository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
