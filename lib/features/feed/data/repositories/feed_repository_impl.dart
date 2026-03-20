import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/feed/data/sources/feed_remote_data_source.dart';
import 'package:reelio/features/feed/domain/entities/reels_feed_page.dart';
import 'package:reelio/features/feed/domain/repositories/feed_repository.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._remoteDataSource);

  final FeedRemoteDataSource _remoteDataSource;

  @override
  FutureEither<ReelsFeedPage> getInitialReels({int limit = 10}) async {
    try {
      final page = await _remoteDataSource.fetchInitialReels(limit: limit);
      return right(page);
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Unable to load reels right now.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEither<ReelsFeedPage> getMoreReels({
    required String lastReelId,
    int limit = 10,
  }) async {
    try {
      final page = await _remoteDataSource.fetchMoreReels(
        lastReelId: lastReelId,
        limit: limit,
      );
      return right(page);
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Unable to load reels right now.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}
