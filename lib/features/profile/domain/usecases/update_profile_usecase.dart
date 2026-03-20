import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({required this.displayName, required this.bio});

  final String displayName;
  final String bio;

  @override
  List<Object?> get props => [displayName, bio];
}

@lazySingleton
class UpdateProfileUseCase
    extends UseCase<FutureEither<ProfileUser>, UpdateProfileParams> {
  UpdateProfileUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  FutureEither<ProfileUser> call(UpdateProfileParams params) {
    return _profileRepository.updateProfile(
      displayName: params.displayName,
      bio: params.bio,
    );
  }
}
