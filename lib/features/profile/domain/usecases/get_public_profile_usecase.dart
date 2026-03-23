import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/entities/public_profile_user.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

class GetPublicProfileParams extends Equatable {
  const GetPublicProfileParams({required this.username});

  final String username;

  @override
  List<Object?> get props => [username];
}

@lazySingleton
class GetPublicProfileUseCase
    extends UseCase<FutureEither<PublicProfileUser>, GetPublicProfileParams> {
  GetPublicProfileUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  FutureEither<PublicProfileUser> call(GetPublicProfileParams params) {
    return _profileRepository.getProfileByUsername(params.username);
  }
}
