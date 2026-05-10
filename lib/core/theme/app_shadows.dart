import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppShadows — Burger Farm Design System Shadow Tokens
///
/// Derived directly from CSS --sh-* variables.
/// All BoxShadow declarations MUST use these tokens.
abstract final class AppShadows {
  // ─── Direct CSS Mapping ──────────────────────────────────────────────────

  /// --sh-btn: Premium CTA button glow shadow
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x6BE8560A), // rgba(232, 86, 10, 0.42)
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1F000000), // rgba(0, 0, 0, 0.12)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// --sh-btn (active/pressed state)
  static const List<BoxShadow> buttonPressed = [
    BoxShadow(
      color: Color(0x4DE8560A), // rgba(232, 86, 10, 0.30)
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];

  /// --sh-card: Subtle card lift shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F271200), // rgba(39, 18, 0, 0.06)
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0D271200), // rgba(39, 18, 0, 0.05)
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// --sh-sheet: Bottom sheet lift shadow
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x17271200), // rgba(39, 18, 0, 0.09)
      blurRadius: 48,
      offset: Offset(0, -12),
    ),
  ];

  /// Selected card border glow
  static const List<BoxShadow> cardSelected = [
    BoxShadow(
      color: Color(0x21E8560A), // rgba(232, 86, 10, 0.13)
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  /// Input focus ring
  static List<BoxShadow> inputFocus = [
    BoxShadow(
      color: AppColors.primaryGlow,
      blurRadius: 0,
      spreadRadius: 3,
    ),
  ];

  /// Brand CTA glow (used on primary buttons)
  static const List<BoxShadow> brandGlow = [
    BoxShadow(
      color: Color(0x66E8560A), // rgba(232,86,10, 0.40)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x33E8560A), // rgba(232,86,10, 0.20)
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Location pin glow (white on orange bg)
  static const List<BoxShadow> glowBrand = [
    BoxShadow(
      color: Color(0x40E8560A),
      blurRadius: 24,
      spreadRadius: 2,
      offset: Offset(0, 0),
    ),
  ];

  /// Float shadow (bottom sheet elevation from orange bg)
  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x1A271200),
      blurRadius: 32,
      offset: Offset(0, -12),
    ),
  ];
}
