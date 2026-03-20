import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reelio/features/auth/presentation/screens/login_screen.dart';
import 'package:reelio/features/auth/presentation/screens/signup_screen.dart';
import 'package:reelio/features/auth/presentation/screens/username_setup_screen.dart';
import 'package:reelio/features/feed/presentation/screens/feed_screen.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/presentation/screens/change_password_screen.dart';
import 'package:reelio/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:reelio/features/profile/presentation/screens/profile_screen.dart';
import 'package:reelio/features/upload/presentation/screens/upload_screen.dart';
import 'package:reelio/shared/widgets/reelio_app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter(this.authBloc);

  final AuthBloc authBloc;

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/app/feed',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isSignupRoute = state.matchedLocation == '/signup';
      final isUsernameSetupRoute = state.matchedLocation == '/pick-username';

      if (authState.status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }

      if (authState.status == AuthStatus.authenticated) {
        if (!authState.user.hasUsername &&
            !isUsernameSetupRoute &&
            !isSignupRoute) {
          return '/pick-username';
        }

        if (authState.user.hasUsername &&
            (isAuthRoute || isUsernameSetupRoute)) {
          return '/app/feed';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/pick-username',
        builder: (context, state) => const UsernameSetupScreen(),
      ),
      GoRoute(path: '/', redirect: (context, state) => '/app/feed'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ReelioAppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/feed',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/upload',
                builder: (context, state) => const UploadScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra;
                      return EditProfileScreen(
                        initialProfile: extra is ProfileUser ? extra : null,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'change-password',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra;
                      return ChangePasswordScreen(
                        canChangePassword: extra as bool? ?? true,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
