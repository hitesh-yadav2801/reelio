import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

class TogglePublicProfileFollowParams extends Equatable {
  const TogglePublicProfileFollowParams({
    required this.targetUserId,
    required this.currentlyFollowing,
  });

  final String targetUserId;
  final bool currentlyFollowing;

  @override
  List<Object?> get props => [targetUserId, currentlyFollowing];
}

@lazySingleton
class TogglePublicProfileFollowUseCase
    extends UseCase<FutureEither<bool>, TogglePublicProfileFollowParams> {
  TogglePublicProfileFollowUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  FutureEither<bool> call(TogglePublicProfileFollowParams params) {
    return _profileRepository.toggleFollowUser(
      targetUserId: params.targetUserId,
      currentlyFollowing: params.currentlyFollowing,
    );
  }
}
