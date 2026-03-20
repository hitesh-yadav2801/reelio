import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

@lazySingleton
class GetCurrentProfileUseCase
    extends UseCase<FutureEither<ProfileUser>, NoParams> {
  GetCurrentProfileUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  FutureEither<ProfileUser> call(NoParams params) {
    return _profileRepository.getCurrentProfile();
  }
}
