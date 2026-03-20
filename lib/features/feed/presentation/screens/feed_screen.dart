import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
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
                      'Reels coming soon...',
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
