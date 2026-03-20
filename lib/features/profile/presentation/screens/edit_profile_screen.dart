import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/presentation/bloc/edit_profile_cubit.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key, this.initialProfile});

  final ProfileUser? initialProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<EditProfileCubit>()..initialize(initialProfile: initialProfile),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
          context.pop(state.profile);
        }

        if (state.status == EditProfileStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        if (state.status == EditProfileStatus.loading ||
            state.status == EditProfileStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return PopScope<void>(
          canPop: !state.hasChanges || state.status == EditProfileStatus.saving,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            final canPop = await _onWillPop(context);
            if (canPop && context.mounted) {
              context.pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.colorSurfaceWarm,
            appBar: AppBar(
              title: const Text('Edit Profile'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () async {
                  final canPop = await _onWillPop(context);
                  if (canPop && context.mounted) {
                    context.pop();
                  }
                },
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space24,
                AppSpacing.space16,
                AppSpacing.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColors.colorSurface,
                            shape: BoxShape.circle,
                          ),
                          child:
                              state.profile.photoUrl != null &&
                                  state.profile.photoUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    state.profile.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person_rounded,
                                              color:
                                                  AppColors.colorNeutralStone,
                                              size: 36,
                                            ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.colorNeutralStone,
                                  size: 36,
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.colorAccentGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: AppColors.colorTextOnAccent,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  TextFormField(
                    key: ValueKey('display_${state.profile.uid}'),
                    initialValue: state.displayName,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Your display name',
                    ),
                    onChanged: context
                        .read<EditProfileCubit>()
                        .displayNameChanged,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  TextFormField(
                    key: ValueKey('bio_${state.profile.uid}'),
                    initialValue: state.bio,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell people about yourself...',
                    ),
                    minLines: 4,
                    maxLines: 4,
                    maxLength: 150,
                    onChanged: context.read<EditProfileCubit>().bioChanged,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'You can update avatar upload flow next. Name and bio '
                    'save to Firebase now.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.colorTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  ElevatedButton(
                    onPressed:
                        state.status == EditProfileStatus.saving ||
                            !state.canSave ||
                            !state.hasChanges
                        ? null
                        : context.read<EditProfileCubit>().saveChanges,
                    child: state.status == EditProfileStatus.saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final state = context.read<EditProfileCubit>().state;
    if (!state.hasChanges || state.status == EditProfileStatus.saving) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('If you go back now, your updates will be lost.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(
                'Keep Editing',
                style: AppTypography.buttonLabel.copyWith(
                  color: AppColors.colorAccentPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: Text(
                'Discard',
                style: AppTypography.buttonLabel.copyWith(
                  color: AppColors.colorError,
                ),
              ),
            ),
          ],
        );
      },
    );

    return shouldDiscard ?? false;
  }
}
