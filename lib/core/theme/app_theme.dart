import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';

/// Reelio app theme following the Hinge-inspired design system.
///
/// Light theme only — per the design philosophy, the app uses a warm,
/// predominantly white canvas with accent colors applied sparingly (90/10 rule).
abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(

      scaffoldBackgroundColor: AppColors.colorBackground,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.colorAccentPrimary,
        secondary: AppColors.colorAccentSecondary,
        onSecondary: AppColors.colorTextOnAccent,
        tertiary: AppColors.colorAccentTertiary,
        error: AppColors.colorError,
        surface: AppColors.colorSurface,
        onSurface: AppColors.colorTextPrimary,
        surfaceContainerHighest: AppColors.colorSurfaceElevated,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.colorSurfaceElevated,
        foregroundColor: AppColors.colorTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading2,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: const Border(
          bottom: BorderSide(color: AppColors.colorDivider),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.colorSurfaceElevated,
        selectedItemColor: AppColors.colorAccentPrimary,
        unselectedItemColor: AppColors.colorNeutralStone,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.colorDivider,
        thickness: 1,
        space: 0,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.colorSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: const BorderSide(color: AppColors.colorDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: const BorderSide(color: AppColors.colorDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: const BorderSide(
            color: AppColors.colorAccentPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: const BorderSide(
            color: AppColors.colorError,
            width: 1.5,
          ),
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.colorTextDisabled,
        ),
        labelStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.colorTextSecondary,
        ),
        floatingLabelStyle: AppTypography.caption.copyWith(
          color: AppColors.colorAccentPrimary,
        ),
      ),

      // Elevated buttons (primary CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorAccentPrimary,
          foregroundColor: AppColors.colorTextOnAccent,
          disabledBackgroundColor: AppColors.colorNeutralPebble,
          disabledForegroundColor: AppColors.colorTextDisabled,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          textStyle: AppTypography.buttonLabel,
          elevation: 0,
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.colorAccentPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          side: const BorderSide(
            color: AppColors.colorAccentPrimary,
            width: 1.5,
          ),
          textStyle: AppTypography.buttonLabel,
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.colorAccentPrimary,
          textStyle: AppTypography.buttonLabel,
        ),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.colorSurfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusMedium),
          ),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.colorSurfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        titleTextStyle: AppTypography.heading2,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.colorTextSecondary,
        ),
        barrierColor: AppColors.colorOverlay,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.colorTextPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.colorTextOnAccent,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.colorAccentPrimary,
      ),

    );
  }
}
