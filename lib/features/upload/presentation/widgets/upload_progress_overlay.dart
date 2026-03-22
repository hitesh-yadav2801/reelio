import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';

class UploadProgressOverlay extends StatelessWidget {
  const UploadProgressOverlay({
    required this.progress,
    required this.onCancel,
    super.key,
  });

  final double progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(AppSpacing.space20),
            decoration: BoxDecoration(
              color: AppColors.colorSurfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.space16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                Text(
                  'Uploading your reel... $percentage%',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.space12),
                TextButton(onPressed: onCancel, child: const Text('Cancel')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
