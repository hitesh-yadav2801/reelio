import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/feed/domain/entities/reels_feed_page.dart';
import 'package:reelio/features/feed/domain/repositories/feed_repository.dart';

class GetInitialReelsParams extends Equatable {
  const GetInitialReelsParams({this.limit = 10});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

@lazySingleton
class GetInitialReelsUseCase
    extends UseCase<FutureEither<ReelsFeedPage>, GetInitialReelsParams> {
  GetInitialReelsUseCase(this._feedRepository);

  final FeedRepository _feedRepository;

  @override
  FutureEither<ReelsFeedPage> call(GetInitialReelsParams params) {
    return _feedRepository.getInitialReels(limit: params.limit);
  }
}
