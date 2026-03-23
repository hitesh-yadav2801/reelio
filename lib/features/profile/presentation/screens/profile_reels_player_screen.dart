import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';
import 'package:reelio/features/feed/presentation/widgets/reel_page_item.dart';
import 'package:reelio/shared/services/reel_video_cache_service.dart';
import 'package:reelio/shared/services/video_preload_manager.dart';

class ProfileReelsPlayerArgs {
  const ProfileReelsPlayerArgs({
    required this.reels,
    required this.initialIndex,
  });

  final List<Reel> reels;
  final int initialIndex;
}

class ProfileReelsPlayerScreen extends StatefulWidget {
  const ProfileReelsPlayerScreen({required this.args, super.key});

  final ProfileReelsPlayerArgs args;

  @override
  State<ProfileReelsPlayerScreen> createState() =>
      _ProfileReelsPlayerScreenState();
}

class _ProfileReelsPlayerScreenState extends State<ProfileReelsPlayerScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late final VideoPreloadManager _preloadManager;

  int _activeIndex = 0;

  List<Reel> get _reels => widget.args.reels;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final safeInitial = widget.args.initialIndex.clamp(0, _reels.length - 1);
    _activeIndex = safeInitial;
    _pageController = PageController(initialPage: safeInitial);
    _preloadManager = VideoPreloadManager(getIt<ReelVideoCacheService>());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _preloadManager.onPageChanged(
          currentIndex: _activeIndex,
          reels: _reels,
        ),
      );
    });
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
      unawaited(_resumeCurrentReel());
    }
  }

  Future<void> _resumeCurrentReel() async {
    if (!mounted || _reels.isEmpty) {
      return;
    }

    await _preloadManager.onPageChanged(
      currentIndex: _activeIndex,
      reels: _reels,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    unawaited(_preloadManager.resetAndDispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reels.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('No reels to play.', style: AppTypography.bodyLarge),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final reel = _reels[index];
              return ReelPageItem(
                key: ValueKey('profile-player:${reel.id}:$index'),
                index: index,
                reel: reel,
                isActive: index == _activeIndex,
                preloadManager: _preloadManager,
                onUsernameTap: () =>
                    _openProfileByUsername(context, reel.username),
                onLikeTap: () => _showComingSoon(context),
                onCommentTap: () => _showComingSoon(context),
                onShareTap: () => _showComingSoon(context),
                isLiked: false,
                isLikeLoading: false,
                likesCount: reel.likesCount,
                commentsCount: reel.commentsCount,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.space8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Colors.white,
                  tooltip: 'Back',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPageChanged(int index) async {
    final previousIndex = _activeIndex;

    setState(() {
      _activeIndex = index;
    });

    await _preloadManager.onPageChanged(
      currentIndex: index,
      reels: _reels,
      previousIndex: previousIndex,
    );
  }

  void _openProfileByUsername(BuildContext context, String username) {
    final sanitized = username.trim().replaceFirst('@', '');
    if (sanitized.isEmpty) {
      return;
    }

    unawaited(_preloadManager.pauseAll());
    final encoded = Uri.encodeComponent(sanitized);
    context.push('/profile/$encoded');
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Coming soon...')));
  }
}
