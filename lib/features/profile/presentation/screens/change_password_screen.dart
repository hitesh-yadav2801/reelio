import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/profile/presentation/bloc/change_password_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.canChangePassword = true});

  final bool canChangePassword;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.colorSurfaceWarm,
        appBar: AppBar(title: const Text('Change Password')),
        body: widget.canChangePassword
            ? BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
                listener: (context, state) {
                  if (state.status == ChangePasswordStatus.error &&
                      state.message != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message!)));
                  }

                  if (state.status == ChangePasswordStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully.'),
                      ),
                    );
                    context.pop();
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Use at least 8 characters and keep it unique.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.colorTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        TextField(
                          obscureText: _hideCurrent,
                          onChanged: context
                              .read<ChangePasswordCubit>()
                              .currentPasswordChanged,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideCurrent = !_hideCurrent;
                                });
                              },
                              icon: Icon(
                                _hideCurrent
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        TextField(
                          obscureText: _hideNew,
                          onChanged: context
                              .read<ChangePasswordCubit>()
                              .newPasswordChanged,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideNew = !_hideNew;
                                });
                              },
                              icon: Icon(
                                _hideNew
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        TextField(
                          obscureText: _hideConfirm,
                          onChanged: context
                              .read<ChangePasswordCubit>()
                              .confirmPasswordChanged,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideConfirm = !_hideConfirm;
                                });
                              },
                              icon: Icon(
                                _hideConfirm
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space24),
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : context.read<ChangePasswordCubit>().submit,
                          child: state.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Update Password'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.colorSurfaceElevated,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                    border: Border.all(color: AppColors.colorDivider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password not available',
                          style: AppTypography.heading2,
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          'This account uses Google sign-in, so password is '
                          'managed by your provider.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.colorTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
