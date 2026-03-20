import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

class SetUsernameParams extends Equatable {
  const SetUsernameParams({required this.username});

  final String username;

  @override
  List<Object?> get props => [username];
}

@lazySingleton
class SetUsernameUseCase extends UseCase<FutureEitherVoid, SetUsernameParams> {
  SetUsernameUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  FutureEitherVoid call(SetUsernameParams params) {
    return _authRepository.setUsername(params.username);
  }
}
