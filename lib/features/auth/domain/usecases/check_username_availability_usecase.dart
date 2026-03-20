import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

class CheckUsernameAvailabilityParams extends Equatable {
  const CheckUsernameAvailabilityParams({required this.username});

  final String username;

  @override
  List<Object?> get props => [username];
}

@lazySingleton
class CheckUsernameAvailabilityUseCase
    extends UseCase<FutureEither<bool>, CheckUsernameAvailabilityParams> {
  CheckUsernameAvailabilityUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  FutureEither<bool> call(CheckUsernameAvailabilityParams params) {
    return _authRepository.isUsernameAvailable(params.username);
  }
}
