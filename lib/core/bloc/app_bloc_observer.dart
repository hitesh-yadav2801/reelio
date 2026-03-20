import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:reelio/core/logging/app_logger.dart';

/// Global BLoC observer for state and error diagnostics.
class AppBlocObserver extends BlocObserver {
  AppBlocObserver({Logger? logger}) : _logger = logger ?? AppLogger.instance;

  final Logger _logger;

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (!kDebugMode) return;
    _logger.d('[BLOC EVENT] ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (!kDebugMode) return;
    _logger.d('[BLOC CHANGE] ${bloc.runtimeType} -> $change');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (!kDebugMode) return;
    _logger.d('[BLOC TRANSITION] ${bloc.runtimeType} -> $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.e(
      '[BLOC ERROR] ${bloc.runtimeType} -> $error',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
