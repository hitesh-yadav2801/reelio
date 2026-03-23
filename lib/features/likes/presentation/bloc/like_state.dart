part of 'like_cubit.dart';

class LikeState extends Equatable {
  const LikeState({
    required this.likedByReel,
    required this.loadingReelIds,
    this.actionErrorMessage,
  });

  const LikeState.initial()
    : likedByReel = const {},
      loadingReelIds = const {},
      actionErrorMessage = null;

  final Map<String, bool> likedByReel;
  final Set<String> loadingReelIds;
  final String? actionErrorMessage;

  LikeState copyWith({
    Map<String, bool>? likedByReel,
    Set<String>? loadingReelIds,
    String? actionErrorMessage,
    bool clearActionError = false,
  }) {
    return LikeState(
      likedByReel: likedByReel ?? this.likedByReel,
      loadingReelIds: loadingReelIds ?? this.loadingReelIds,
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [likedByReel, loadingReelIds, actionErrorMessage];
}
