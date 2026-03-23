import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/feed/domain/entities/reels_feed_page.dart';
import 'package:reelio/features/feed/domain/repositories/feed_repository.dart';

class GetMoreReelsParams extends Equatable {
  const GetMoreReelsParams({required this.lastReelId, this.limit = 10});

  final String lastReelId;
  final int limit;

  @override
  List<Object?> get props => [lastReelId, limit];
}

@lazySingleton
class GetMoreReelsUseCase
    extends UseCase<FutureEither<ReelsFeedPage>, GetMoreReelsParams> {
  GetMoreReelsUseCase(this._feedRepository);

  final FeedRepository _feedRepository;

  @override
  FutureEither<ReelsFeedPage> call(GetMoreReelsParams params) {
    return _feedRepository.getMoreReels(
      lastReelId: params.lastReelId,
      limit: params.limit,
    );
  }
}
