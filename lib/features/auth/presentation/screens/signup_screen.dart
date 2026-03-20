import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/auth/presentation/bloc/signup_cubit.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignupCubit>(),
      child: const SignupView(),
    );
  }
}

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.colorTextPrimary),
      ),
      body: BlocListener<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state.status == SignupStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'Unable to create your account right now.',
                ),
              ),
            );
          }
          if (state.status == SignupStatus.success) {
            context.go('/app/feed');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.space16),
                Text(
                  'Join Reelio',
                  style: AppTypography.display,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'Create an account to start sharing your world.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.colorTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space32),

                // Name Field
                TextField(
                  onChanged: (name) =>
                      context.read<SignupCubit>().nameChanged(name),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Jane Doe',
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),

                // Email Field
                TextField(
                  onChanged: (email) =>
                      context.read<SignupCubit>().emailChanged(email),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'jane@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.space16),

                // Password Field
                TextField(
                  onChanged: (password) =>
                      context.read<SignupCubit>().passwordChanged(password),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: AppSpacing.space32),

                // Signup Button
                BlocBuilder<SignupCubit, SignupState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.status == SignupStatus.submitting
                          ? null
                          : () => context.read<SignupCubit>().signUp(),
                      child: state.status == SignupStatus.submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign Up'),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.space32),

                // Footer
                Center(
                  child: Text(
                    'By signing up, you agree to our Terms and Privacy Policy.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.colorTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
