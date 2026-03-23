import 'package:reelio/core/utils/typedefs.dart';

abstract class LikeRepository {
  FutureEither<bool> getLikeStatus({required String reelId});

  FutureEither<bool> toggleLike({
    required String reelId,
    required bool currentlyLiked,
  });
}
