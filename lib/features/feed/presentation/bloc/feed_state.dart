part of 'feed_cubit.dart';

enum FeedStatus { initial, loading, loaded, loadingMore, refreshing, error }

class FeedState extends Equatable {
  const FeedState({
    required this.status,
    required this.reels,
    required this.hasMore,
    required this.currentIndex,
    this.lastReelId,
    this.errorMessage,
    this.actionErrorMessage,
  });

  const FeedState.initial()
    : status = FeedStatus.initial,
      reels = const [],
      hasMore = true,
      currentIndex = 0,
      lastReelId = null,
      errorMessage = null,
      actionErrorMessage = null;

  final FeedStatus status;
  final List<Reel> reels;
  final bool hasMore;
  final int currentIndex;
  final String? lastReelId;
  final String? errorMessage;
  final String? actionErrorMessage;

  FeedState copyWith({
    FeedStatus? status,
    List<Reel>? reels,
    bool? hasMore,
    int? currentIndex,
    String? lastReelId,
    String? errorMessage,
    String? actionErrorMessage,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return FeedState(
      status: status ?? this.status,
      reels: reels ?? this.reels,
      hasMore: hasMore ?? this.hasMore,
      currentIndex: currentIndex ?? this.currentIndex,
      lastReelId: lastReelId ?? this.lastReelId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    reels,
    hasMore,
    currentIndex,
    lastReelId,
    errorMessage,
    actionErrorMessage,
  ];
}
