import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';
import 'package:video_player/video_player.dart';

class ReelOverlay extends StatelessWidget {
  const ReelOverlay({
    required this.reel,
    required this.onUsernameTap,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.isLiked,
    required this.likesCount,
    required this.commentsCount,
    this.controller,
    this.isLikeLoading = false,
    super.key,
  });

  final Reel reel;
  final VideoPlayerController? controller;
  final VoidCallback onUsernameTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final bool isLiked;
  final bool isLikeLoading;
  final int likesCount;
  final int commentsCount;

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
                _ActionColumn(
                  isLiked: isLiked,
                  isLikeLoading: isLikeLoading,
                  likesCount: likesCount,
                  commentsCount: commentsCount,
                  onLikeTap: onLikeTap,
                  onCommentTap: onCommentTap,
                ),
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
  const _ActionColumn({
    required this.isLiked,
    required this.isLikeLoading,
    required this.likesCount,
    required this.commentsCount,
    required this.onLikeTap,
    required this.onCommentTap,
  });

  final bool isLiked;
  final bool isLikeLoading;
  final int likesCount;
  final int commentsCount;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionItem(
          icon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: isLiked ? const Color(0xFFFF4D6D) : Colors.white,
          label: _formatCount(likesCount),
          onTap: isLikeLoading ? null : onLikeTap,
        ),
        const SizedBox(height: AppSpacing.space16),
        _ActionItem(
          icon: Icons.chat_bubble_outline_rounded,
          label: _formatCount(commentsCount),
          onTap: onCommentTap,
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
  const _ActionItem({
    required this.icon,
    required this.label,
    this.iconColor = Colors.white,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: iconColor,
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
      ),
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
