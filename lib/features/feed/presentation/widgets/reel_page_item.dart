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
    super.key,
  });

  final int index;
  final Reel reel;
  final bool isActive;
  final VideoPreloadManager preloadManager;
  final VoidCallback onUsernameTap;

  @override
  State<ReelPageItem> createState() => _ReelPageItemState();
}

class _ReelPageItemState extends State<ReelPageItem> {
  VideoPlayerController? _controller;
  bool _isControllerLoading = true;
  bool _hasControllerError = false;
  bool _isBuffering = false;

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
    _controller?.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  Future<void> _attachController() async {
    setState(() {
      _isControllerLoading = true;
      _hasControllerError = false;
    });

    try {
      final controller = await widget.preloadManager.getOrCreateController(
        index: widget.index,
        videoUrl: widget.reel.videoUrl,
      );

      if (!mounted) {
        return;
      }

      _controller?.removeListener(_handleControllerUpdate);
      _controller = controller;
      _controller?.addListener(_handleControllerUpdate);

      setState(() {
        _isControllerLoading = false;
        _hasControllerError = false;
        _isBuffering = controller.value.isBuffering;
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
    if (!mounted || controller == null) {
      return;
    }

    final isBuffering = controller.value.isBuffering;
    if (isBuffering == _isBuffering) {
      return;
    }

    setState(() {
      _isBuffering = isBuffering;
    });
  }

  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (widget.isActive) {
      await controller.play();
    } else {
      await controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _buildVideoLayer(controller)),
        const Positioned.fill(child: _LegibilityOverlay()),
        ReelOverlay(
          reel: widget.reel,
          controller: controller,
          onUsernameTap: widget.onUsernameTap,
        ),
        if (_isControllerLoading || _isBuffering)
          const Positioned.fill(child: _BufferingIndicator()),
      ],
    );
  }

  Widget _buildVideoLayer(VideoPlayerController? controller) {
    if (_hasControllerError) {
      return const _VideoErrorState();
    }

    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF1A1A1A));
    }

    return ColoredBox(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
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
