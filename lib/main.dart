import 'package:flutter/material.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/router/app_router.dart';
import 'package:reelio/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const ReelioApp());
}

class ReelioApp extends StatelessWidget {
  const ReelioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reelio',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
