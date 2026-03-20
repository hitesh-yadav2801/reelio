import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SignOutUseCase extends UseCase<FutureEitherVoid, NoParams> {
  SignOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  FutureEitherVoid call(NoParams params) {
    return _authRepository.signOut();
  }
}
