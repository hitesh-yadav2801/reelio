import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';
import 'package:reelio/features/feed/presentation/widgets/reel_overlay.dart';
import 'package:reelio/shared/services/video_preload_manager.dart';
import 'package:video_player/video_player.dart';

class ReelPageItem extends StatefulWidget {
  const ReelPageItem({
    required this.index,
    required this.reel,
    required this.isActive,
    required this.preloadManager,
    required this.onUsernameTap,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.isLiked,
    required this.likesCount,
    required this.commentsCount,
    this.isLikeLoading = false,
    super.key,
  });

  final int index;
  final Reel reel;
  final bool isActive;
  final VideoPreloadManager preloadManager;
  final VoidCallback onUsernameTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final bool isLiked;
  final bool isLikeLoading;
  final int likesCount;
  final int commentsCount;

  @override
  State<ReelPageItem> createState() => _ReelPageItemState();
}

class _ReelPageItemState extends State<ReelPageItem> {
  VideoPlayerController? _controller;
  int _attachRequestId = 0;
  bool _isControllerLoading = true;
  bool _hasControllerError = false;
  bool _isBuffering = false;
  bool _showPlaybackIndicator = false;
  IconData _playbackIndicatorIcon = Icons.pause_rounded;
  Timer? _playbackIndicatorTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_attachController());
  }

  @override
  void didUpdateWidget(covariant ReelPageItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final reelChanged =
        oldWidget.reel.id != widget.reel.id ||
        oldWidget.reel.videoUrl != widget.reel.videoUrl ||
        oldWidget.index != widget.index;

    if (reelChanged) {
      unawaited(_attachController());
      return;
    }

    if (oldWidget.isActive != widget.isActive) {
      unawaited(_syncPlayback());
    }
  }

  @override
  void dispose() {
    _playbackIndicatorTimer?.cancel();
    _controller?.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  Future<void> _attachController() async {
    final requestId = ++_attachRequestId;

    _controller?.removeListener(_handleControllerUpdate);
    _controller = null;

    setState(() {
      _isControllerLoading = true;
      _hasControllerError = false;
      _isBuffering = false;
    });

    try {
      final controller = await widget.preloadManager.getOrCreateController(
        index: widget.index,
        videoUrl: widget.reel.videoUrl,
      );

      if (!mounted ||
          requestId != _attachRequestId ||
          !_isControllerUsable(controller)) {
        return;
      }

      _controller = controller;
      controller.addListener(_handleControllerUpdate);

      setState(() {
        _isControllerLoading = false;
        _hasControllerError = false;
        _isBuffering = _safeIsBuffering(controller);
      });

      await _syncPlayback();
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        _isControllerLoading = false;
        _hasControllerError = true;
      });
    }
  }

  void _handleControllerUpdate() {
    final controller = _controller;
    if (!mounted || controller == null || !_isControllerUsable(controller)) {
      return;
    }

    final isBuffering = _safeIsBuffering(controller);
    if (isBuffering == _isBuffering) {
      return;
    }

    setState(() {
      _isBuffering = isBuffering;
    });
  }

  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !_isControllerUsable(controller)) {
      return;
    }

    final isInitialized = _safeIsInitialized(controller);
    if (!isInitialized) {
      return;
    }

    try {
      if (widget.isActive) {
        await controller.play();
      } else {
        await controller.pause();
      }
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasControllerError = true;
      });
    }
  }

  Future<void> _onReelTap() async {
    if (!widget.isActive) {
      return;
    }

    final controller = _controller;
    if (controller == null || !_isControllerUsable(controller)) {
      return;
    }

    final isInitialized = _safeIsInitialized(controller);
    if (!isInitialized) {
      return;
    }

    try {
      if (controller.value.isPlaying) {
        await controller.pause();
        _showPlaybackStateIndicator(Icons.pause_rounded);
      } else {
        await controller.play();
        _showPlaybackStateIndicator(Icons.play_arrow_rounded);
      }
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasControllerError = true;
      });
    }
  }

  void _showPlaybackStateIndicator(IconData icon) {
    _playbackIndicatorTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _playbackIndicatorIcon = icon;
      _showPlaybackIndicator = true;
    });

    _playbackIndicatorTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _showPlaybackIndicator = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onReelTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _buildVideoLayer(controller)),
          const Positioned.fill(child: _LegibilityOverlay()),
          ReelOverlay(
            reel: widget.reel,
            controller: controller,
            onUsernameTap: widget.onUsernameTap,
            onLikeTap: widget.onLikeTap,
            onCommentTap: widget.onCommentTap,
            onShareTap: widget.onShareTap,
            isLiked: widget.isLiked,
            isLikeLoading: widget.isLikeLoading,
            likesCount: widget.likesCount,
            commentsCount: widget.commentsCount,
          ),
          if (_isControllerLoading || _isBuffering)
            const Positioned.fill(child: _BufferingIndicator()),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showPlaybackIndicator ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space12),
                      child: Icon(
                        _playbackIndicatorIcon,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer(VideoPlayerController? controller) {
    if (_hasControllerError) {
      return const _VideoErrorState();
    }

    if (controller == null || !_isControllerUsable(controller)) {
      return const ColoredBox(color: Color(0xFF1A1A1A));
    }

    final isInitialized = _safeIsInitialized(controller);
    if (!isInitialized) {
      return const ColoredBox(color: Color(0xFF1A1A1A));
    }

    final size = _safeControllerSize(controller);
    if (size == null || size.width == 0 || size.height == 0) {
      return const ColoredBox(color: Color(0xFF1A1A1A));
    }

    return ColoredBox(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  bool _isControllerUsable(VideoPlayerController controller) {
    try {
      controller.value;
      return true;
    } on Object {
      return false;
    }
  }

  bool _safeIsInitialized(VideoPlayerController controller) {
    try {
      return controller.value.isInitialized;
    } on Object {
      return false;
    }
  }

  bool _safeIsBuffering(VideoPlayerController controller) {
    try {
      return controller.value.isBuffering;
    } on Object {
      return false;
    }
  }

  Size? _safeControllerSize(VideoPlayerController controller) {
    try {
      return controller.value.size;
    } on Object {
      return null;
    }
  }
}

class _LegibilityOverlay extends StatelessWidget {
  const _LegibilityOverlay();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66000000), Color(0x00000000)],
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0xAA000000)],
            ),
          ),
        ),
      ],
    );
  }
}

class _BufferingIndicator extends StatelessWidget {
  const _BufferingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.space12),
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      ),
    );
  }
}

class _VideoErrorState extends StatelessWidget {
  const _VideoErrorState();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded, color: Colors.white70),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Video unavailable',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
