part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  const ProfileState({
    required this.status,
    required this.user,
    required this.reels,
    this.errorMessage,
    this.actionErrorMessage,
  });

  const ProfileState.initial()
    : status = ProfileStatus.initial,
      user = ProfileUser.empty,
      reels = const [],
      errorMessage = null,
      actionErrorMessage = null;

  final ProfileStatus status;
  final ProfileUser user;
  final List<ProfileReel> reels;
  final String? errorMessage;
  final String? actionErrorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileUser? user,
    List<ProfileReel>? reels,
    String? errorMessage,
    String? actionErrorMessage,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      reels: reels ?? this.reels,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    reels,
    errorMessage,
    actionErrorMessage,
  ];
}
