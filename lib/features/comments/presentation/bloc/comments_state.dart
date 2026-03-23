part of 'comments_cubit.dart';

enum CommentsStatus { initial, loading, loaded, error }

class CommentsState extends Equatable {
  const CommentsState({
    required this.status,
    required this.comments,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isPosting,
    this.reelId,
    this.lastCommentId,
    this.errorMessage,
    this.actionErrorMessage,
  });

  const CommentsState.initial()
    : status = CommentsStatus.initial,
      comments = const [],
      hasMore = true,
      isLoadingMore = false,
      isPosting = false,
      reelId = null,
      lastCommentId = null,
      errorMessage = null,
      actionErrorMessage = null;

  final CommentsStatus status;
  final List<Comment> comments;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isPosting;
  final String? reelId;
  final String? lastCommentId;
  final String? errorMessage;
  final String? actionErrorMessage;

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comment>? comments,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isPosting,
    String? reelId,
    String? lastCommentId,
    String? errorMessage,
    String? actionErrorMessage,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPosting: isPosting ?? this.isPosting,
      reelId: reelId ?? this.reelId,
      lastCommentId: lastCommentId ?? this.lastCommentId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    comments,
    hasMore,
    isLoadingMore,
    isPosting,
    reelId,
    lastCommentId,
    errorMessage,
    actionErrorMessage,
  ];
}
