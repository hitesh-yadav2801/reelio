import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/likes/domain/repositories/like_repository.dart';

class GetLikeStatusParams extends Equatable {
  const GetLikeStatusParams({required this.reelId});

  final String reelId;

  @override
  List<Object?> get props => [reelId];
}

@lazySingleton
class GetLikeStatusUseCase
    extends UseCase<FutureEither<bool>, GetLikeStatusParams> {
  GetLikeStatusUseCase(this._likeRepository);

  final LikeRepository _likeRepository;

  @override
  FutureEither<bool> call(GetLikeStatusParams params) {
    return _likeRepository.getLikeStatus(reelId: params.reelId);
  }
}
