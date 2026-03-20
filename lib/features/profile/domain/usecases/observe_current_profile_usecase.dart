import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

@lazySingleton
class ObserveCurrentProfileUseCase
    extends StreamUseCase<ProfileUser, NoParams> {
  ObserveCurrentProfileUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  Stream<ProfileUser> call(NoParams params) {
    return _profileRepository.observeCurrentProfile();
  }
}
