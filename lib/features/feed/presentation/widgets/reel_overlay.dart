import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';
import 'package:video_player/video_player.dart';

class ReelOverlay extends StatelessWidget {
  const ReelOverlay({
    required this.reel,
    required this.onUsernameTap,
    this.controller,
    super.key,
  });

  final Reel reel;
  final VideoPlayerController? controller;
  final VoidCallback onUsernameTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        child: Column(
          children: [
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _ReelDetails(reel: reel, onUsernameTap: onUsernameTap),
                ),
                const SizedBox(width: AppSpacing.space16),
                _ActionColumn(reel: reel),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            _VideoProgress(controller: controller),
            const SizedBox(height: AppSpacing.space12),
          ],
        ),
      ),
    );
  }
}

class _ReelDetails extends StatelessWidget {
  const _ReelDetails({required this.reel, required this.onUsernameTap});

  final Reel reel;
  final VoidCallback onUsernameTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onUsernameTap,
          child: Text(
            '@${reel.username}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.username.copyWith(
              color: Colors.white,
              shadows: const [Shadow(color: Color(0x80000000), blurRadius: 8)],
            ),
          ),
        ),
        if (reel.caption.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            reel.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              shadows: const [Shadow(color: Color(0x80000000), blurRadius: 8)],
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionColumn extends StatelessWidget {
  const _ActionColumn({required this.reel});

  final Reel reel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionItem(
          icon: Icons.favorite_border_rounded,
          label: _formatCount(reel.likesCount),
        ),
        const SizedBox(height: AppSpacing.space16),
        _ActionItem(
          icon: Icons.chat_bubble_outline_rounded,
          label: _formatCount(reel.commentsCount),
        ),
        const SizedBox(height: AppSpacing.space16),
        const _ActionItem(icon: Icons.ios_share_rounded, label: 'Share'),
      ],
    );
  }

  static String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.white,
          shadows: const [Shadow(color: Color(0x80000000), blurRadius: 8)],
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            shadows: const [Shadow(color: Color(0x80000000), blurRadius: 8)],
          ),
        ),
      ],
    );
  }
}

class _VideoProgress extends StatelessWidget {
  const _VideoProgress({this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final videoController = controller;

    if (videoController == null || !videoController.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 3,
          value: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 3,
        child: VideoProgressIndicator(
          videoController,
          allowScrubbing: false,
          colors: VideoProgressColors(
            playedColor: Colors.white,
            bufferedColor: Colors.white.withValues(alpha: 0.5),
            backgroundColor: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}
