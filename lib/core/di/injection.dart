import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/di/injection.config.dart';

/// Global GetIt service locator instance.
final getIt = GetIt.instance;

/// Initializes all dependencies registered with @injectable annotations.
///
/// Must be called before `runApp()` in `main.dart`.
@InjectableInit()
void configureDependencies() => getIt.init();
