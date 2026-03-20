import 'package:logger/logger.dart';

/// Central logger for application diagnostics.
abstract final class AppLogger {
  static final Logger instance = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
    ),
  );
}
