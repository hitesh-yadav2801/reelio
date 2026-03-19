import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.video_library_rounded,
                size: 48,
                color: AppColors.colorNeutralStone.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.space12),
              Text(
                'Feed is coming next',
                style: AppTypography.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Auth and profile are now active. Next step is the reels '
                'engine with autoplay, preload, and caching.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.colorTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
