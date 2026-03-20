import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:reelio/features/feed/presentation/widgets/feed_shimmer.dart';
import 'package:reelio/features/feed/presentation/widgets/reel_page_item.dart';
import 'package:reelio/shared/services/video_preload_manager.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver {
  late final PageController _pageController;
  late final VideoPreloadManager _preloadManager;

  int _activeIndex = 0;
  String _playbackBootstrapToken = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _preloadManager = getIt<VideoPreloadManager>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    unawaited(_preloadManager.resetAndDispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_preloadManager.pauseAll());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_resumeActiveReel());
    }
  }

  Future<void> _resumeActiveReel() async {
    if (!mounted) {
      return;
    }

    final feedState = context.read<FeedCubit>().state;
    if (feedState.reels.isEmpty) {
      return;
    }

    final index = _activeIndex.clamp(0, feedState.reels.length - 1);
    await _preloadManager.onPageChanged(
      currentIndex: index,
      reels: feedState.reels,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return BlocProvider(
      create: (_) => getIt<FeedCubit>()..fetchInitial(),
      child: BlocConsumer<FeedCubit, FeedState>(
        listener: (context, state) {
          if (state.actionErrorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionErrorMessage!)));
            context.read<FeedCubit>().clearActionError();
          }

          if (state.status == FeedStatus.refreshing) {
            _playbackBootstrapToken = '';
            return;
          }

          if (state.status == FeedStatus.loaded && state.reels.isNotEmpty) {
            _bootstrapPlaybackIfNeeded(state);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.colorBackground,
            body: Stack(
              children: [
                Positioned.fill(child: _buildFeedContent(context, state)),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: topInset + 72,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x99000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topInset + AppSpacing.space8,
                  left: AppSpacing.space16,
                  right: AppSpacing.space8,
                  child: Row(
                    children: [
                      Text(
                        'Reels',
                        style: AppTypography.heading2.copyWith(
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Color(0x80000000), blurRadius: 8),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/search'),
                        icon: const Icon(Icons.search_rounded),
                        color: Colors.white,
                        tooltip: 'Search',
                      ),
                    ],
                  ),
                ),
                if (state.status == FeedStatus.loadingMore)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.space8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedContent(BuildContext context, FeedState state) {
    if ((state.status == FeedStatus.initial ||
            state.status == FeedStatus.loading) &&
        state.reels.isEmpty) {
      return const FeedShimmer();
    }

    if (state.status == FeedStatus.error && state.reels.isEmpty) {
      return _FeedError(
        message: state.errorMessage ?? 'Unable to load reels right now.',
        onRetry: () => context.read<FeedCubit>().fetchInitial(),
      );
    }

    if (state.reels.isEmpty) {
      return const _FeedEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final feedCubit = context.read<FeedCubit>();
        await _preloadManager.resetAndDispose();
        if (!context.mounted) {
          return;
        }

        _activeIndex = 0;
        _playbackBootstrapToken = '';
        await feedCubit.refresh();
      },
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: state.reels.length,
        onPageChanged: (index) => _onPageChanged(context, state, index),
        itemBuilder: (context, index) {
          final reel = state.reels[index];

          return ReelPageItem(
            index: index,
            reel: reel,
            isActive: index == _activeIndex,
            preloadManager: _preloadManager,
            onUsernameTap: () => _openProfileByUsername(context, reel.username),
          );
        },
      ),
    );
  }

  Future<void> _onPageChanged(
    BuildContext context,
    FeedState state,
    int nextIndex,
  ) async {
    final feedCubit = context.read<FeedCubit>();
    final previousIndex = _activeIndex;

    setState(() {
      _activeIndex = nextIndex;
    });
    feedCubit.setCurrentIndex(nextIndex);

    await _preloadManager.onPageChanged(
      currentIndex: nextIndex,
      reels: state.reels,
      previousIndex: previousIndex,
    );

    if (!mounted) {
      return;
    }

    if (nextIndex >= state.reels.length - 3) {
      unawaited(feedCubit.loadMore());
    }
  }

  void _bootstrapPlaybackIfNeeded(FeedState state) {
    final safeIndex = state.currentIndex.clamp(0, state.reels.length - 1);
    final token = '${state.reels.first.id}:${state.reels.length}:$safeIndex';

    if (_playbackBootstrapToken == token) {
      return;
    }

    _playbackBootstrapToken = token;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (_activeIndex != safeIndex) {
        setState(() {
          _activeIndex = safeIndex;
        });
      }

      if (_pageController.hasClients) {
        final currentPage = _pageController.page?.round();
        if (currentPage != safeIndex) {
          _pageController.jumpToPage(safeIndex);
        }
      }

      unawaited(
        _preloadManager.onPageChanged(
          currentIndex: safeIndex,
          reels: state.reels,
        ),
      );
    });
  }

  void _openProfileByUsername(BuildContext context, String username) {
    final sanitized = username.trim().replaceFirst('@', '');
    if (sanitized.isEmpty) {
      return;
    }

    final encoded = Uri.encodeComponent(sanitized);
    context.push('/profile/$encoded');
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.space16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 44,
              color: AppColors.colorNeutralStone.withValues(alpha: 0.65),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'No reels available yet.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
