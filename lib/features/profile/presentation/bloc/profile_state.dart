part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  const ProfileState({
    required this.status,
    required this.user,
    this.errorMessage,
  });

  const ProfileState.initial()
    : status = ProfileStatus.initial,
      user = ProfileUser.empty,
      errorMessage = null;

  final ProfileStatus status;
  final ProfileUser user;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
