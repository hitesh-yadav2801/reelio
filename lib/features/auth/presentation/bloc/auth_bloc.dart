import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';
import 'package:reelio/features/auth/domain/usecases/observe_auth_state_usecase.dart';
import 'package:reelio/features/auth/domain/usecases/sign_out_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._observeAuthStateUseCase, this._signOutUseCase)
    : super(const AuthState.initial()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);

    add(const AuthSubscriptionRequested());
  }
  final ObserveAuthStateUseCase _observeAuthStateUseCase;
  final SignOutUseCase _signOutUseCase;
  StreamSubscription<ReelioUser>? _userSubscription;

  void _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    _userSubscription?.cancel();
    _userSubscription = _observeAuthStateUseCase(
      const NoParams(),
    ).listen((user) => add(AuthUserChanged(user)));
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
    await _signOutUseCase(const NoParams());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
