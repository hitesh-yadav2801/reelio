import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/presentation/bloc/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProfileStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Unable to load profile.',
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProfileCubit>().loadProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = state.user;
          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _TopBar(
                  username: '@${user.username}',
                  onLogoutPressed: () => _confirmLogout(context),
                ),
                _ProfileHeader(
                  user: user,
                  onEditProfile: () async {
                    final result = await context.push<ProfileUser>(
                      '/app/profile/edit',
                      extra: user,
                    );
                    if (!context.mounted) return;

                    if (result != null) {
                      context.read<ProfileCubit>().profileUpdated(result);
                    } else {
                      await context.read<ProfileCubit>().loadProfile();
                    }
                  },
                  onChangePassword: () => context.push(
                    '/app/profile/change-password',
                    extra: user.canChangePassword,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('You will need to sign in again to continue.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: Text(
                'Log out',
                style: AppTypography.buttonLabel.copyWith(
                  color: AppColors.colorError,
                ),
              ),
            ),
          ],
        );
      },
    );

    if ((shouldLogout ?? false) && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.username, required this.onLogoutPressed});

  final String username;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.colorSurfaceElevated,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: AppSpacing.space48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.colorDivider)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  username,
                  textAlign: TextAlign.center,
                  style: AppTypography.username,
                ),
              ),
              IconButton(
                onPressed: onLogoutPressed,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Log out',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.onEditProfile,
    required this.onChangePassword,
  });

  final ProfileUser user;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space24,
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.colorNeutralSand,
                  AppColors.colorAccentPrimary,
                ],
              ),
            ),
            child: ClipOval(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.colorSurface),
                child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? Image.network(
                        user.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person_rounded,
                              color: AppColors.colorNeutralStone,
                              size: 36,
                            ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.colorNeutralStone,
                        size: 36,
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            user.displayName,
            style: AppTypography.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            '@${user.username}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.colorTextSecondary,
            ),
          ),
          if (user.bio.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space12),
            Text(
              user.bio,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(label: 'Reels', value: '${user.reelsCount}'),
              Container(
                height: 32,
                width: 1,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space24,
                ),
                color: AppColors.colorDivider,
              ),
              _StatItem(label: 'Followers', value: '${user.followerCount}'),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),
          OutlinedButton(
            onPressed: onEditProfile,
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: AppSpacing.space12),
          OutlinedButton(
            onPressed: user.canChangePassword ? onChangePassword : null,
            child: const Text('Change Password'),
          ),
          if (!user.canChangePassword)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space8),
              child: Text(
                'Password is managed by your sign-in provider.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.colorTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: AppSpacing.space24),
          _ReelsSection(reelsCount: user.reelsCount),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.heading2.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.colorTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _ReelsSection extends StatelessWidget {
  const _ReelsSection({required this.reelsCount});

  final int reelsCount;

  @override
  Widget build(BuildContext context) {
    if (reelsCount == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.space32),
        child: Column(
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              color: AppColors.colorNeutralPebble,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'No reels yet.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.colorTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reelsCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.space2,
        crossAxisSpacing: AppSpacing.space2,
      ),
      itemBuilder: (context, index) {
        return const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.colorSurface),
          child: Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: AppColors.colorNeutralStone,
            ),
          ),
        );
      },
    );
  }
}
