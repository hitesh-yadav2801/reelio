import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/search/domain/entities/search_user.dart';

abstract class SearchRepository {
  FutureEither<List<SearchUser>> searchUsers(String query);

  FutureEither<bool> toggleFollow({
    required String targetUserId,
    required bool currentlyFollowing,
  });
}
