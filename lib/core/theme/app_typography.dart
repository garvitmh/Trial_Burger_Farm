import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography system implementing Montreux Classic and Recoleta
class AppTypography {
  AppTypography._();

  static const String displayFont = 'MontreuxClassic';
  static const String bodyFont = 'Recoleta';
  
  // Colors (from AppColors, keeping aliases for compatibility with the spec)
  static Color get brown => AppColors.brown;
  static Color get brownMuted => AppColors.brownMuted;
  static Color get brand => AppColors.brand;
  static const Color white = Colors.white;

  /// Display / headline font builder (for backward compatibility in UI)
  static TextStyle display({
    double size = 16,
    FontWeight weight = FontWeight.w900,
    Color? color,
    double letterSpacing = 0.15,
    double? height,
    List<Shadow>? shadows,
    FontStyle? style,
  }) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: size,
      fontWeight: weight,
      color: color ?? brown,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
      fontStyle: style,
    );
  }

  /// Body / serif font builder (for backward compatibility in UI)
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
    double? height,
    FontStyle? style,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: weight,
      color: color ?? brown,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: style,
      decoration: decoration,
    );
  }

  // ── Pre-defined styles (backward compatibility) ──────────
  static TextStyle get splashTitle => textTheme.displayLarge!;
  static TextStyle get onboardingHeadline => textTheme.displayMedium!;
  static TextStyle get screenTitle => textTheme.titleLarge!;
  static TextStyle get bodyLarge => textTheme.bodyLarge!;
  static TextStyle get labelSmall => textTheme.labelSmall!;

  static TextTheme get textTheme => TextTheme(
    // Display Large - Splash brand
    displayLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 64,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.03 * 64, // -1.92
      height: 0.85,
      color: white,
    ),
    
    // Display Medium - Onboarding headlines
    displayMedium: TextStyle(
      fontFamily: displayFont,
      fontSize: 40,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.025 * 40, // -1.0
      height: 1.05,
      color: brown,
    ),
    
    // Headline Large - Login/Location
    headlineLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.02 * 36, // -0.72
      height: 1.1,
      color: brown,
    ),
    
    // Headline Medium - Section titles
    headlineMedium: TextStyle(
      fontFamily: displayFont,
      fontSize: 26,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.02 * 26, // -0.52
      height: 1.1,
      color: brown,
    ),
    
    // Title Large - App bar titles
    titleLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 19,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.07 * 19, // 1.33
      height: 1.0,
      color: brown,
    ),
    
    // Title Medium - Card titles, prices
    titleMedium: TextStyle(
      fontFamily: displayFont,
      fontSize: 18,
      fontWeight: FontWeight.w900,
      height: 1.0,
      color: brown,
    ),
    
    // Body Large - Descriptions
    bodyLarge: TextStyle(
      fontFamily: bodyFont,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.55,
      color: brownMuted,
    ),
    
    // Body Medium - Regular text
    bodyMedium: TextStyle(
      fontFamily: bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: brown,
    ),
    
    // Label Large - Buttons, CTAs
    labelLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.01 * 17, // 0.17
      height: 1.0,
      color: white,
    ),
    
    // Label Medium - Badges, captions
    labelMedium: TextStyle(
      fontFamily: bodyFont,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.17 * 11, // 1.87
      height: 1.0,
      color: brownMuted,
    ),
    
    // Label Small - Tiny labels
    labelSmall: TextStyle(
      fontFamily: bodyFont,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2 * 10, // 2.0
      height: 1.2,
      color: brand,
    ),
  );
}

class AppTextStyles {
  // Brand logo style
  static const TextStyle brandLogo = TextStyle(
    fontFamily: AppTypography.displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 4.4, // 0.2em
    color: Colors.white,
  );
  
  // Splash tagline
  static const TextStyle splashTagline = TextStyle(
    fontFamily: AppTypography.displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.2, // 0.01em
    color: Colors.white,
  );
  
  // Input field text
  static TextStyle get inputText => TextStyle(
    fontFamily: AppTypography.bodyFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2, // 0.01em
    color: AppTypography.brown,
  );
  
  // Price display
  static TextStyle get price => TextStyle(
    fontFamily: AppTypography.displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: AppTypography.brown,
  );
  
  // Strikethrough price
  static TextStyle get priceStrikethrough => TextStyle(
    fontFamily: AppTypography.displayFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white.withOpacity(0.6),
    decoration: TextDecoration.lineThrough,
  );
  
  // Category label uppercase
  static TextStyle get categoryLabel => TextStyle(
    fontFamily: AppTypography.bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.4, // 0.2em
    color: AppTypography.brown,
  );
  
  // Trust badge
  static const TextStyle trustBadge = TextStyle(
    fontFamily: AppTypography.bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1A7A38), // success
  );
}
