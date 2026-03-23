import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reelio/core/bloc/app_bloc_observer.dart';
import 'package:reelio/core/config/supabase_config.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/router/app_router.dart';
import 'package:reelio/core/theme/app_theme.dart';
import 'package:reelio/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reelio/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:reelio/firebase_options.dart';
import 'package:reelio/shared/services/connectivity_service.dart';
import 'package:reelio/shared/services/reel_upload_remote_config_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase is not configured. Update SupabaseConfig.url and '
      'SupabaseConfig.anonKey before running the app.',
    );
  }
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  configureDependencies();
  await getIt<ConnectivityService>().initialize();
  await getIt<ReelUploadRemoteConfigService>().initialize();
  runApp(const ReelioApp());
}

class ReelioApp extends StatelessWidget {
  const ReelioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<ConnectivityCubit>()),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final appRouter = AppRouter(authBloc, AppLaunchGate());

          return MaterialApp.router(
            title: 'Reelio',
            theme: AppTheme.light,
            routerConfig: appRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
