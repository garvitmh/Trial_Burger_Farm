// ============================================================================
// DEPRECATED: Use package:burger_farm_app/core/constants/app_typography.dart
// This file re-exports typography classes from the canonical location.
// ============================================================================
export '../constants/app_typography.dart';
export '../constants/app_colors.dart' show AppColors;

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Backward-compatible builder methods (deprecated — use const TextStyles instead).
/// These non-const getters exist for files that haven't migrated yet.
class AppTypographyHelpers {
  AppTypographyHelpers._();

  /// Helper for splash title style.
  static TextStyle get splashTitle => AppTypography.display64;

  /// Helper for onboarding headline style.
  static TextStyle get onboardingHeadline => AppTypography.display40;

  /// Helper for screen title style.
  static TextStyle get screenTitle => AppTypography.display26;
}

// For backward compatibility — these were defined in the old file
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle brandLogo = TextStyle(
    fontFamily: AppTypography.displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 4.4,
    color: Colors.white,
  );

  static const TextStyle splashTagline = TextStyle(
    fontFamily: AppTypography.displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.2,
    color: Colors.white,
  );

  static TextStyle get priceStrikethrough => TextStyle(
    fontFamily: AppTypography.displayFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.6),
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle get categoryLabel => TextStyle(
    fontFamily: AppTypography.bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.4,
    color: AppColors.brown,
  );

  static const TextStyle trustBadge = TextStyle(
    fontFamily: AppTypography.bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1A7A38),
  );
}
