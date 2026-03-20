part of 'change_password_cubit.dart';

enum ChangePasswordStatus { initial, editing, submitting, success, error }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.message,
  });

  final ChangePasswordStatus status;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final String? message;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    String? message,
    bool clearMessage = false,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentPassword,
    newPassword,
    confirmPassword,
    message,
  ];

  @override
  bool get stringify => false;
}
