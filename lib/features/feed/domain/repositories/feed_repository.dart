import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/feed/domain/entities/reels_feed_page.dart';

abstract class FeedRepository {
  FutureEither<ReelsFeedPage> getInitialReels({int limit = 10});

  FutureEither<ReelsFeedPage> getMoreReels({
    required String lastReelId,
    int limit = 10,
  });
}
