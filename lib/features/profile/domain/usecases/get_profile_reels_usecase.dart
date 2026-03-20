import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/entities/profile_reel.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

class GetProfileReelsParams extends Equatable {
  const GetProfileReelsParams({required this.userId, this.limit = 60});

  final String userId;
  final int limit;

  @override
  List<Object?> get props => [userId, limit];
}

@lazySingleton
class GetProfileReelsUseCase
    extends UseCase<FutureEither<List<ProfileReel>>, GetProfileReelsParams> {
  GetProfileReelsUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  FutureEither<List<ProfileReel>> call(GetProfileReelsParams params) {
    return _profileRepository.getReelsByUserId(
      userId: params.userId,
      limit: params.limit,
    );
  }
}
