import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/auth/presentation/bloc/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Brand Heading (DM Serif Display)
                Text(
                  'Welcome to Reelio',
                  style: AppTypography.display,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'Experience the best in short-form video.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.colorTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Email Field
                TextField(
                  onChanged: (email) =>
                      context.read<LoginCubit>().emailChanged(email),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'hello@reelio.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.space16),

                // Password Field
                TextField(
                  onChanged: (password) =>
                      context.read<LoginCubit>().passwordChanged(password),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: AppSpacing.space24),

                // Login Button
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context
                                .read<LoginCubit>()
                                .logInWithCredentials(),
                      child: state.isSubmittingCredentials
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.space16),

                // Google Sign In
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    return OutlinedButton.icon(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.read<LoginCubit>().logInWithGoogle(),
                      icon: state.isSubmittingGoogle
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SvgPicture.asset(
                              'assets/icons/google.svg',
                              height: 24,
                              width: 24,
                            ),
                      label: Text(
                        state.isSubmittingGoogle
                            ? 'Signing in with Google...'
                            : 'Continue with Google',
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Signup link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.buttonLabel.copyWith(
                          color: AppColors.colorAccentPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
