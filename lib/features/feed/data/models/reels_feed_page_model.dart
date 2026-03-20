import 'package:reelio/features/feed/domain/entities/reel.dart';
import 'package:reelio/features/feed/domain/entities/reels_feed_page.dart';

class ReelsFeedPageModel extends ReelsFeedPage {
  const ReelsFeedPageModel({
    required super.reels,
    required super.hasMore,
    super.lastReelId,
  });

  factory ReelsFeedPageModel.empty() {
    return const ReelsFeedPageModel(reels: [], hasMore: false);
  }

  ReelsFeedPageModel copyWith({
    List<Reel>? reels,
    bool? hasMore,
    String? lastReelId,
  }) {
    return ReelsFeedPageModel(
      reels: reels ?? this.reels,
      hasMore: hasMore ?? this.hasMore,
      lastReelId: lastReelId ?? this.lastReelId,
    );
  }
}
