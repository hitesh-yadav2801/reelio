import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

enum ConnectivityStatus { checking, online, offline }

@lazySingleton
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.checking;
  bool _isInitialized = false;

  ConnectivityStatus get currentStatus => _currentStatus;
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    final initialResults = await _connectivity.checkConnectivity();
    _emitStatus(_toStatus(initialResults));

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _emitStatus(_toStatus(results));
    });
  }

  void _emitStatus(ConnectivityStatus nextStatus) {
    if (_currentStatus == nextStatus) {
      return;
    }
    _currentStatus = nextStatus;
    _statusController.add(nextStatus);
  }

  ConnectivityStatus _toStatus(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((it) => it == ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
  }
}
