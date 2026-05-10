import 'package:flutter/material.dart';

/// AppColors — Burger Farm Design System Color Tokens
///
/// Derived from the official CSS design token sheet (styles.css :root variables).
/// All colors are semantically named. Widgets MUST reference these tokens only.
/// DO NOT use hardcoded hex values anywhere in the UI layer.
///
/// CSS Variable Mapping:
///   --o         → primary
///   --o2        → primaryDark
///   --o-glow    → primaryGlow
///   --cream     → surface
///   --warm      → surfaceWarm
///   --brown     → textPrimary
///   --brown2    → textSecondary
///   --muted     → textMuted
///   --line      → border
///   --green     → success
///   --red       → error
abstract final class AppColors {
  // ─── Brand / Primary ────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE8560A);
  static const Color primaryDark = Color(0xFFC94208);
  static const Color primaryGlow = Color(0x38E8560A); // rgba(232,86,10,0.22)

  // ─── Surfaces ───────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFBF7F2);      // --cream
  static const Color surfaceWarm = Color(0xFFF5EFE6);  // --warm
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color background = Color(0xFF130A02);   // App dark background

  // ─── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF271200);    // --brown
  static const Color textSecondary = Color(0xFF4A2800);  // --brown2
  static const Color textMuted = Color(0x6B271200);      // rgba(39,18,0, 0.42)
  static const Color textOnDark = Color(0xE0FFFFFF);     // rgba(255,255,255,0.88)
  static const Color textOnDarkFaint = Color(0x38FFFFFF);// rgba(255,255,255,0.22)

  // ─── Borders & Dividers ─────────────────────────────────────────────────
  static const Color border = Color(0xFFEBE1D6);         // --line

  // ─── Semantic Status ────────────────────────────────────────────────────
  static const Color success = Color(0xFF1A7A38);        // --green
  static const Color error = Color(0xFFC0001A);          // --red
  static const Color warning = Color(0xFFB45309);

  // ─── Status Badge Fills ─────────────────────────────────────────────────
  static const Color badgeOpenBg = Color(0x1A1A7A38);
  static const Color badgeClosedBg = Color(0x14C0001A);
  static const Color badgeSoonBg = Color(0x1AD97706);

  // ─── Overlays ───────────────────────────────────────────────────────────
  static const Color overlayLight = Color(0x14FFFFFF);   // rgba(255,255,255,0.08)
  static const Color overlayDark = Color(0x14000000);

  // ─── Dark Mode Preparation ──────────────────────────────────────────────
  // These are placeholders for the future dark theme implementation.
  static const Color darkSurface = Color(0xFF1C0E05);
  static const Color darkBorder = Color(0xFF2E1A0A);

  // ─── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x17FFFFFF), Color(0x00FFFFFF)],
  );

  static const RadialGradient splashRadialGlow = RadialGradient(
    center: Alignment(0, -0.4),
    radius: 0.8,
    colors: [Color(0x1EFFFFFF), Colors.transparent],
  );
}
