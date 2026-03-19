import 'package:flutter/material.dart';

/// All color tokens from the Reelio UI/UX design spec.
///
/// Based on Hinge's brand palette with the 90/10 rule:
/// white and warm surfaces occupy ≥90% of any screen, accent colors ≤10%.
abstract final class AppColors {
  // ── Core Surfaces ──
  static const colorBackground = Color(0xFFFFFFFF);
  static const colorSurfaceWarm = Color(0xFFF7F3EF);
  static const colorSurface = Color(0xFFF2EDE8);
  static const colorSurfaceElevated = Color(0xFFFFFFFF);
  static const colorOverlay = Color(0x8C000000); // #000 at 55%
  static const colorVideoScrim = Color(0xFF000000);

  // ── Text Colors ──
  static const colorTextPrimary = Color(0xFF1A1A1A);
  static const colorTextSecondary = Color(0xFF666666);
  static const colorTextDisabled = Color(0xFFADADAD);
  static const colorTextOnAccent = Color(0xFFFFFFFF);

  // ── Accent & Interactive ──
  static const colorAccentPrimary = Color(0xFF75457D); // Lilac
  static const colorAccentSecondary = Color(0xFF9F81A5); // Mauve
  static const colorAccentTertiary = Color(0xFFC7C7E5); // Mist
  static const colorAccentGreen = Color(0xFF097270); // Kelp
  static const colorAccentAlert = Color(0xFFD45847); // Coral

  // ── Neutral Tones ──
  static const colorNeutralSand = Color(0xFFCCAC9F);
  static const colorNeutralPebble = Color(0xFFEEE1DB);
  static const colorNeutralStone = Color(0xFF484848);
  static const colorDivider = Color(0xFFE8E0D8);

  // ── Semantic ──
  static const colorLiked = colorAccentPrimary;
  static const colorUnliked = colorTextPrimary;
  static const colorUnlikedOnVideo = Color(0xFFFFFFFF);
  static const colorSuccess = colorAccentGreen;
  static const colorError = colorAccentAlert;
  static const colorBuffering = colorAccentSecondary;
}
