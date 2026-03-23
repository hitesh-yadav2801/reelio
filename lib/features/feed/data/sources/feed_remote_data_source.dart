import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/feed/data/models/reel_model.dart';
import 'package:reelio/features/feed/data/models/reels_feed_page_model.dart';

abstract class FeedRemoteDataSource {
  Future<ReelsFeedPageModel> fetchInitialReels({int limit = 10});

  Future<ReelsFeedPageModel> fetchMoreReels({
    required String lastReelId,
    int limit = 10,
  });
}

@LazySingleton(as: FeedRemoteDataSource)
class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  FeedRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  @override
  Future<ReelsFeedPageModel> fetchInitialReels({int limit = 10}) async {
    return _fetchReels(limit: limit);
  }

  @override
  Future<ReelsFeedPageModel> fetchMoreReels({
    required String lastReelId,
    int limit = 10,
  }) async {
    return _fetchReels(lastReelId: lastReelId, limit: limit);
  }

  Future<ReelsFeedPageModel> _fetchReels({
    required int limit,
    String? lastReelId,
  }) async {
    var query = _reelsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastReelId != null && lastReelId.trim().isNotEmpty) {
      final lastDoc = await _reelsCollection.doc(lastReelId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    final models = snapshot.docs
        .map(ReelModel.fromFirestore)
        .where((reel) => reel.videoUrl.isNotEmpty)
        .toList(growable: false);

    final lastVisibleId = snapshot.docs.isNotEmpty
        ? snapshot.docs.last.id
        : null;

    return ReelsFeedPageModel(
      reels: models,
      hasMore: snapshot.docs.length == limit,
      lastReelId: lastVisibleId,
    );
  }
}
