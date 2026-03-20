import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SignInWithGoogleUseCase
    extends UseCase<FutureEither<ReelioUser>, NoParams> {
  SignInWithGoogleUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  FutureEither<ReelioUser> call(NoParams params) {
    return _authRepository.signInWithGoogle();
  }
}
