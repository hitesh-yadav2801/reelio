import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/comments/domain/entities/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({required this.comment, super.key});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.colorSurface,
            backgroundImage:
                comment.userAvatarUrl != null &&
                    comment.userAvatarUrl!.isNotEmpty
                ? NetworkImage(comment.userAvatarUrl!)
                : null,
            child:
                comment.userAvatarUrl == null || comment.userAvatarUrl!.isEmpty
                ? const Icon(Icons.person_rounded, size: 18)
                : null,
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '@${comment.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(comment.text, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'now';
    }

    if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    }

    if (diff.inDays < 1) {
      return '${diff.inHours}h';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
