import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:shimmer/shimmer.dart';

class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.colorSurface,
      highlightColor: AppColors.colorNeutralPebble,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: AppColors.colorSurface)),
          Positioned(
            right: AppSpacing.space16,
            bottom: 150,
            child: Column(
              children: [
                _circle(),
                const SizedBox(height: AppSpacing.space16),
                _circle(),
                const SizedBox(height: AppSpacing.space16),
                _circle(),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.space16,
            right: 90,
            bottom: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line(width: 120),
                const SizedBox(height: AppSpacing.space8),
                _line(width: double.infinity),
                const SizedBox(height: AppSpacing.space8),
                _line(width: 160),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 3, color: AppColors.colorNeutralSand),
          ),
        ],
      ),
    );
  }

  Widget _circle() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _line({required double width}) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
