part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);
  final ReelioUser user;

  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
