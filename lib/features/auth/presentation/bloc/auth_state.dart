part of 'auth_bloc.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  const AuthState._({
    this.status = AuthStatus.initial,
    this.user = ReelioUser.empty,
  });

  const AuthState.initial() : this._();

  const AuthState.authenticated(ReelioUser user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.loading() : this._(status: AuthStatus.loading);
  final AuthStatus status;
  final ReelioUser user;

  @override
  List<Object?> get props => [status, user];
}
