import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

class ChangePasswordParams extends Equatable {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

@lazySingleton
class ChangePasswordUseCase
    extends UseCase<FutureEitherVoid, ChangePasswordParams> {
  ChangePasswordUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  FutureEitherVoid call(ChangePasswordParams params) {
    return _profileRepository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
