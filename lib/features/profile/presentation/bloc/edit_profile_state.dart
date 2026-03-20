part of 'edit_profile_cubit.dart';

enum EditProfileStatus { initial, loading, ready, saving, success, error }

class EditProfileState extends Equatable {
  const EditProfileState({
    required this.status,
    required this.profile,
    required this.displayName,
    required this.bio,
    this.errorMessage,
  });

  const EditProfileState.initial()
    : status = EditProfileStatus.initial,
      profile = ProfileUser.empty,
      displayName = '',
      bio = '',
      errorMessage = null;

  factory EditProfileState.ready(ProfileUser profile) {
    return EditProfileState(
      status: EditProfileStatus.ready,
      profile: profile,
      displayName: profile.displayName,
      bio: profile.bio,
    );
  }

  factory EditProfileState.success(ProfileUser profile) {
    return EditProfileState(
      status: EditProfileStatus.success,
      profile: profile,
      displayName: profile.displayName,
      bio: profile.bio,
    );
  }

  final EditProfileStatus status;
  final ProfileUser profile;
  final String displayName;
  final String bio;
  final String? errorMessage;

  bool get hasChanges {
    return displayName.trim() != profile.displayName.trim() ||
        bio.trim() != profile.bio.trim();
  }

  bool get canSave => displayName.trim().isNotEmpty;

  EditProfileState copyWith({
    EditProfileStatus? status,
    ProfileUser? profile,
    String? displayName,
    String? bio,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, displayName, bio, errorMessage];
}
