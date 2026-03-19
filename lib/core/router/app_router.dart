import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App-wide route configuration using GoRouter.
///
/// All routes are defined here. Deep link support is built in.
/// Auth guard and redirect logic will be added in Phase 2.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _PlaceholderScreen(),
    ),
  ],
);

/// Temporary placeholder screen until the splash/auth screens are built.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Reelio'),
      ),
    );
  }
}
