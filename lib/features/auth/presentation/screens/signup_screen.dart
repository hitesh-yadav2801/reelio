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

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.colorTextPrimary),
      ),
      body: BlocConsumer<SignupCubit, SignupState>(
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
            context.go('/pick-username');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space24,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    TextFormField(
                      onChanged: (name) =>
                          context.read<SignupCubit>().nameChanged(name),
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Jane Doe',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    TextFormField(
                      onChanged: (email) =>
                          context.read<SignupCubit>().emailChanged(email),
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'jane@example.com',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    TextFormField(
                      onChanged: (password) =>
                          context.read<SignupCubit>().passwordChanged(password),
                      validator: _validatePassword,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    TextFormField(
                      onChanged: (confirmPassword) => context
                          .read<SignupCubit>()
                          .confirmPasswordChanged(confirmPassword),
                      validator: (value) =>
                          _validateConfirmPassword(value, state.password),
                      obscureText: _hideConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirmPassword = !_hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              if (!(_formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              context.read<SignupCubit>().signUp();
                            },
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign Up'),
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    Center(
                      child: Text(
                        'By signing up, you agree to our Terms '
                        'and Privacy Policy.',
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
          );
        },
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, String password) {
    final confirmPassword = value ?? '';
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
