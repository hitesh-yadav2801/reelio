import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reelio/core/theme/app_colors.dart';

/// Typography styles for Reelio.
///
/// Uses DM Serif Display (display/headings) + Inter (body/UI)
/// as open equivalents to Hinge's proprietary typefaces.
abstract final class AppTypography {
  // ── Display ──
  static TextStyle display = GoogleFonts.dmSerifDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 34 / 28,
    color: AppColors.colorTextPrimary,
  );

  // ── Headings ──
  static TextStyle heading1 = GoogleFonts.dmSerifDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 28 / 22,
    color: AppColors.colorTextPrimary,
  );

  static TextStyle heading2 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.colorTextPrimary,
  );

  // ── Body ──
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.colorTextPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.colorTextPrimary,
  );

  // ── Caption ──
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.colorTextPrimary,
  );

  // ── Button ──
  static TextStyle buttonLabel = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    color: AppColors.colorTextPrimary,
  );

  // ── Username ──
  static TextStyle username = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
    color: AppColors.colorTextPrimary,
  );

  // ── Overline / Tag ──
  static TextStyle overline = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    color: AppColors.colorTextPrimary,
  );
}
