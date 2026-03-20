import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/auth/presentation/bloc/username_setup_cubit.dart';
import 'package:reelio/features/auth/presentation/models/username_check_status.dart';
import 'package:reelio/shared/input_formatters/lower_case_text_formatter.dart';

class UsernameSetupScreen extends StatelessWidget {
  const UsernameSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UsernameSetupCubit>(),
      child: const _UsernameSetupView(),
    );
  }
}

class _UsernameSetupView extends StatelessWidget {
  const _UsernameSetupView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Choose Username'),
      ),
      body: BlocListener<UsernameSetupCubit, UsernameSetupState>(
        listener: (context, state) {
          if (state.status == UsernameSetupStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          if (state.status == UsernameSetupStatus.success) {
            context.go('/app/feed');
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pick your username',
                  style: AppTypography.display,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'You only do this once. '
                  'This username will be visible across Reelio.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.colorTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space32),
                BlocBuilder<UsernameSetupCubit, UsernameSetupState>(
                  builder: (context, state) {
                    return TextField(
                      onChanged: context
                          .read<UsernameSetupCubit>()
                          .usernameChanged,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9_]'),
                        ),
                        LengthLimitingTextInputFormatter(20),
                        LowerCaseTextFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'jane_doe',
                        prefixText: '@',
                        suffixIcon: _usernameStatusIcon(state),
                        helperText: _usernameHelperText(state),
                        helperStyle: AppTypography.caption.copyWith(
                          color: _usernameHelperColor(state),
                        ),
                        helperMaxLines: 2,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.space24),
                BlocBuilder<UsernameSetupCubit, UsernameSetupState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.canSubmit
                          ? () => context.read<UsernameSetupCubit>().submit()
                          : null,
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _usernameStatusIcon(UsernameSetupState state) {
    switch (state.usernameStatus) {
      case UsernameCheckStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case UsernameCheckStatus.available:
        return const Icon(
          Icons.check_circle_rounded,
          color: AppColors.colorSuccess,
        );
      case UsernameCheckStatus.taken:
        return const Icon(Icons.cancel_rounded, color: AppColors.colorError);
      case UsernameCheckStatus.initial:
      case UsernameCheckStatus.invalid:
      case UsernameCheckStatus.error:
        return null;
    }
  }

  String _usernameHelperText(UsernameSetupState state) {
    switch (state.usernameStatus) {
      case UsernameCheckStatus.initial:
        return '3-20 chars: lowercase letters, numbers, underscores.';
      case UsernameCheckStatus.invalid:
        return state.usernameMessage ??
            'Use lowercase letters, numbers, and underscores only.';
      case UsernameCheckStatus.checking:
        return 'Checking availability...';
      case UsernameCheckStatus.available:
        return 'Username is available.';
      case UsernameCheckStatus.taken:
        return 'Username is already taken.';
      case UsernameCheckStatus.error:
        return state.usernameMessage ??
            'Unable to verify username right now. Please try again.';
    }
  }

  Color _usernameHelperColor(UsernameSetupState state) {
    switch (state.usernameStatus) {
      case UsernameCheckStatus.available:
        return AppColors.colorSuccess;
      case UsernameCheckStatus.taken:
      case UsernameCheckStatus.invalid:
      case UsernameCheckStatus.error:
        return AppColors.colorError;
      case UsernameCheckStatus.initial:
      case UsernameCheckStatus.checking:
        return AppColors.colorTextSecondary;
    }
  }
}
