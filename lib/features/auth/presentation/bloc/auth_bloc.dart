import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState.initial()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);

    add(const AuthSubscriptionRequested());
  }
  final AuthRepository _authRepository;
  StreamSubscription<ReelioUser>? _userSubscription;

  void _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    _userSubscription?.cancel();
    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user == ReelioUser.empty) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(event.user));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
