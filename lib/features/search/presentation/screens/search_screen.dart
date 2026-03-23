import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/search/domain/entities/search_user.dart';
import 'package:reelio/features/search/presentation/bloc/search_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(title: const Text('Search')),
      body: BlocConsumer<SearchCubit, SearchState>(
        listener: (context, state) {
          if (state.actionErrorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionErrorMessage!)));
            context.read<SearchCubit>().clearActionError();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space16,
                  AppSpacing.space12,
                  AppSpacing.space16,
                  AppSpacing.space8,
                ),
                child: TextField(
                  onChanged: context.read<SearchCubit>().queryChanged,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search users',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchState state) {
    if (state.showPrompt) {
      return const _CenteredMessage(message: 'Search for people.');
    }

    if (state.status == SearchStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SearchStatus.error) {
      return _CenteredMessage(
        message: state.errorMessage ?? 'Unable to search users.',
      );
    }

    if (state.status == SearchStatus.empty) {
      return const _CenteredMessage(message: 'No matching users found.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        AppSpacing.space24,
      ),
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = state.results[index];
        return _SearchUserRow(
          user: user,
          onTap: () {
            final encoded = Uri.encodeComponent(user.username);
            context.push('/profile/$encoded');
          },
          onToggleFollow: () => context.read<SearchCubit>().toggleFollow(user),
        );
      },
    );
  }
}

class _SearchUserRow extends StatelessWidget {
  const _SearchUserRow({
    required this.user,
    required this.onTap,
    required this.onToggleFollow,
  });

  final SearchUser user;
  final VoidCallback onTap;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.space12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.colorSurface,
              backgroundImage:
                  user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.colorNeutralStone,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    '@${user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.colorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            SizedBox(
              width: 124,
              child: user.isFollowing
                  ? OutlinedButton(
                      onPressed: user.isUpdating ? null : onToggleFollow,
                      child: user.isUpdating
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Following'),
                    )
                  : ElevatedButton(
                      onPressed: user.isUpdating ? null : onToggleFollow,
                      child: user.isUpdating
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Follow'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.colorTextSecondary,
          ),
        ),
      ),
    );
  }
}
