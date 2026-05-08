import 'package:flutter/material.dart';

/// Exact color tokens from the Burger Farm design system.
/// Sourced from Tailwind config:
///   brand: { DEFAULT: '#E8560A', hover: '#C94208', light: '#FFF0E5' }
///   brown: { DEFAULT: '#271200', muted: rgba(39,18,0,0.42), light: rgba(39,18,0,0.06) }
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────
  static const Color brand      = Color(0xFFE8560A);
  static const Color brandHover = Color(0xFFC94208);
  static const Color brandLight = Color(0xFFFFF0E5);

  // ── Neutrals ───────────────────────────────────────────
  static const Color brown  = Color(0xFF271200);
  static const Color cream  = Color(0xFFFBF7F2);
  static const Color line   = Color(0xFFEBE1D6);
  static const Color warmBg = Color(0xFFF5EFE6);

  // ── Semantic ───────────────────────────────────────────
  static const Color success = Color(0xFF1A7A38);
  static const Color danger  = Color(0xFFC0001A);

  // ── Derived (opacity) ──────────────────────────────────
  static Color get brownMuted => brown.withOpacity(0.42);
  static Color get brownLight => brown.withOpacity(0.06);
  static Color get whiteMuted => Colors.white.withOpacity(0.80);
}
