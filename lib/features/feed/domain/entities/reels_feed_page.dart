import 'package:equatable/equatable.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';

class ReelsFeedPage extends Equatable {
  const ReelsFeedPage({
    required this.reels,
    required this.hasMore,
    this.lastReelId,
  });

  final List<Reel> reels;
  final bool hasMore;
  final String? lastReelId;

  @override
  List<Object?> get props => [reels, hasMore, lastReelId];
}
