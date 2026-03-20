import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorSurfaceWarm,
      appBar: AppBar(title: const Text('New Reel')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_upload_rounded,
                size: 48,
                color: AppColors.colorAccentPrimary,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Upload flow placeholder',
                style: AppTypography.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Bottom navigation is set. Full video picking and upload '
                'progress will be added in the upload phase.',
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
