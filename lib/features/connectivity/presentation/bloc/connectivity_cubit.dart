import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/shared/services/connectivity_service.dart';

class ConnectivityState extends Equatable {
  const ConnectivityState({required this.status});

  final ConnectivityStatus status;

  bool get isOnline => status == ConnectivityStatus.online;
  bool get isOffline => status == ConnectivityStatus.offline;

  @override
  List<Object?> get props => [status];
}

@injectable
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._connectivityService)
      : super(ConnectivityState(status: _connectivityService.currentStatus)) {
    _subscription = _connectivityService.statusStream.listen((status) {
      emit(ConnectivityState(status: status));
    });
  }

  final ConnectivityService _connectivityService;
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
