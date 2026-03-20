import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class ObserveAuthStateUseCase extends StreamUseCase<ReelioUser, NoParams> {
  ObserveAuthStateUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Stream<ReelioUser> call(NoParams params) {
    return _authRepository.user;
  }
}
