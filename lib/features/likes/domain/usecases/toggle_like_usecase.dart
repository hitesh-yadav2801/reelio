import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/likes/domain/repositories/like_repository.dart';

class ToggleLikeParams extends Equatable {
  const ToggleLikeParams({required this.reelId, required this.currentlyLiked});

  final String reelId;
  final bool currentlyLiked;

  @override
  List<Object?> get props => [reelId, currentlyLiked];
}

@lazySingleton
class ToggleLikeUseCase extends UseCase<FutureEither<bool>, ToggleLikeParams> {
  ToggleLikeUseCase(this._likeRepository);

  final LikeRepository _likeRepository;

  @override
  FutureEither<bool> call(ToggleLikeParams params) {
    return _likeRepository.toggleLike(
      reelId: params.reelId,
      currentlyLiked: params.currentlyLiked,
    );
  }
}
