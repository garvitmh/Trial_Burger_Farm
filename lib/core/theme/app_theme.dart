import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// AppTheme — Burger Farm Master ThemeData Configuration
///
/// All MaterialApp instances MUST reference AppTheme.light() as their theme.
/// This ensures consistent Material component styling everywhere.
/// Dark theme is a prepared stub for future implementation.
abstract final class AppTheme {
  /// Primary light theme — Production ready.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      fontFamily: AppTypography.fontUI,
      scaffoldBackgroundColor: AppColors.surface,

      // ─── AppBar ───────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontDisplay,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),

      // ─── ElevatedButton ───────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabel,
          elevation: 0,
        ),
      ),

      // ─── OutlinedButton ───────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabelSm,
        ),
      ),

      // ─── InputDecoration ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: AppTypography.inputPlaceholder.copyWith(
          color: AppColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // ─── Card ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // ─── SnackBar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMd.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── BottomSheet ──────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        elevation: 0,
      ),

      // ─── Divider ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ─── Text ─────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(),
    );
  }

  /// Dark theme stub — prepared for future implementation.
  static ThemeData dark() {
    // TODO(phase-5): Implement full dark theme using AppColors dark tokens.
    return light().copyWith(
      scaffoldBackgroundColor: AppColors.darkSurface,
      colorScheme: _lightColorScheme.copyWith(
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      ),
    );
  }

  // ─── Private Builders ─────────────────────────────────────────────────────

  static ColorScheme get _lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      );

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: AppTypography.displaySplash,
      displayMedium: AppTypography.headlineXL,
      displaySmall: AppTypography.headlineLg,
      headlineLarge: AppTypography.headlineLg,
      headlineMedium: AppTypography.headlineMd,
      headlineSmall: AppTypography.sectionLabel,
      titleLarge: AppTypography.bodyMd,
      titleMedium: AppTypography.buttonLabel,
      titleSmall: AppTypography.buttonLabelSm,
      bodyLarge: AppTypography.bodyMd,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
      labelLarge: AppTypography.buttonLabel,
      labelMedium: AppTypography.labelAction,
      labelSmall: AppTypography.labelMicro,
    );
  }
}
