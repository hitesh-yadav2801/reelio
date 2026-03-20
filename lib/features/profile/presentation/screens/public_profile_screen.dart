import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/profile/domain/entities/profile_reel.dart';
import 'package:reelio/features/profile/domain/entities/public_profile_user.dart';
import 'package:reelio/features/profile/presentation/bloc/public_profile_cubit.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({required this.username, super.key});

  final String username;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PublicProfileCubit>()..loadByUsername(username),
      child: const _PublicProfileView(),
    );
  }
}

class _PublicProfileView extends StatelessWidget {
  const _PublicProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<PublicProfileCubit, PublicProfileState>(
        listener: (context, state) {
          if (state.actionErrorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionErrorMessage!)));
            context.read<PublicProfileCubit>().clearActionError();
          }
        },
        builder: (context, state) {
          if (state.status == PublicProfileStatus.loading ||
              state.status == PublicProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PublicProfileStatus.error || state.user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage ?? 'Unable to load this profile.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    ElevatedButton(
                      onPressed: () => context
                          .read<PublicProfileCubit>()
                          .loadByUsername(state.username),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = state.user!;

          return RefreshIndicator(
            onRefresh: () => context.read<PublicProfileCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space16,
                AppSpacing.space16,
                AppSpacing.space24,
              ),
              children: [
                _ProfileHeader(
                  user: user,
                  isFollowUpdating: state.isFollowUpdating,
                  onToggleFollow: () =>
                      context.read<PublicProfileCubit>().toggleFollow(),
                ),
                const SizedBox(height: AppSpacing.space24),
                _ReelsGrid(reels: state.reels),
                const SizedBox(height: AppSpacing.space24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.isFollowUpdating,
    required this.onToggleFollow,
  });

  final PublicProfileUser user;
  final bool isFollowUpdating;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        size: 36,
                        color: AppColors.colorNeutralStone,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: AppColors.colorNeutralStone,
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
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.space24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Stat(label: 'Reels', value: '${user.reelsCount}'),
            _divider(),
            _Stat(label: 'Followers', value: '${user.followerCount}'),
            _divider(),
            _Stat(label: 'Following', value: '${user.followingCount}'),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        if (!user.isCurrentUser)
          SizedBox(
            width: 150,
            child: user.isFollowing
                ? OutlinedButton(
                    onPressed: isFollowUpdating ? null : onToggleFollow,
                    child: isFollowUpdating
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Following'),
                  )
                : ElevatedButton(
                    onPressed: isFollowUpdating ? null : onToggleFollow,
                    child: isFollowUpdating
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Follow'),
                  ),
          )
        else
          OutlinedButton(
            onPressed: () => context.go('/app/profile'),
            child: const Text('Open My Profile Tab'),
          ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 32,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      color: AppColors.colorDivider,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

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

class _ReelsGrid extends StatelessWidget {
  const _ReelsGrid({required this.reels});

  final List<ProfileReel> reels;

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.space24),
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
      itemCount: reels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.space2,
        crossAxisSpacing: AppSpacing.space2,
      ),
      itemBuilder: (context, index) {
        final reel = reels[index];
        final thumbnailUrl = reel.thumbnailUrl;

        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
          return DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.colorSurface),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.colorNeutralStone,
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.space4),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

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
