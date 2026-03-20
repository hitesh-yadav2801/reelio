part of 'username_setup_cubit.dart';

class UsernameSetupState extends Equatable {
  const UsernameSetupState({
    this.username = '',
    this.usernameStatus = UsernameCheckStatus.initial,
    this.usernameMessage,
    this.status = UsernameSetupStatus.initial,
    this.errorMessage,
  });

  final String username;
  final UsernameCheckStatus usernameStatus;
  final String? usernameMessage;
  final UsernameSetupStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == UsernameSetupStatus.submitting;

  bool get canSubmit {
    return usernameStatus == UsernameCheckStatus.available && !isSubmitting;
  }

  UsernameSetupState copyWith({
    String? username,
    UsernameCheckStatus? usernameStatus,
    String? usernameMessage,
    UsernameSetupStatus? status,
    String? errorMessage,
    bool clearUsernameMessage = false,
    bool clearError = false,
  }) {
    return UsernameSetupState(
      username: username ?? this.username,
      usernameStatus: usernameStatus ?? this.usernameStatus,
      usernameMessage: clearUsernameMessage
          ? null
          : (usernameMessage ?? this.usernameMessage),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    username,
    usernameStatus,
    usernameMessage,
    status,
    errorMessage,
  ];

  @override
  bool get stringify => false;
}
