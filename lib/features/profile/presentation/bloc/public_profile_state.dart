part of 'public_profile_cubit.dart';

enum PublicProfileStatus { initial, loading, loaded, error }

class PublicProfileState extends Equatable {
  const PublicProfileState({
    required this.username,
    required this.status,
    required this.reels,
    required this.isFollowUpdating,
    this.user,
    this.errorMessage,
    this.actionErrorMessage,
  });

  const PublicProfileState.initial()
    : username = '',
      status = PublicProfileStatus.initial,
      reels = const [],
      user = null,
      isFollowUpdating = false,
      errorMessage = null,
      actionErrorMessage = null;

  final String username;
  final PublicProfileStatus status;
  final PublicProfileUser? user;
  final List<ProfileReel> reels;
  final bool isFollowUpdating;
  final String? errorMessage;
  final String? actionErrorMessage;

  PublicProfileState copyWith({
    String? username,
    PublicProfileStatus? status,
    PublicProfileUser? user,
    List<ProfileReel>? reels,
    bool? isFollowUpdating,
    String? errorMessage,
    String? actionErrorMessage,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return PublicProfileState(
      username: username ?? this.username,
      status: status ?? this.status,
      user: user ?? this.user,
      reels: reels ?? this.reels,
      isFollowUpdating: isFollowUpdating ?? this.isFollowUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    username,
    status,
    user,
    reels,
    isFollowUpdating,
    errorMessage,
    actionErrorMessage,
  ];
}
