// ============================================================================
// DESIGN SYSTEM - COLORS
// Extracted from HTML Tailwind config and CSS variables
// ============================================================================
import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Brand ───
  static const Color brand = Color(0xFFE8560A);
  static const Color brandHover = Color(0xFFC94208);
  static const Color brandLight = Color(0xFFFFF0E5);
  static const Color brandGlow = Color(0x40E8560A);

  // ─── Brown (Text Primary) ───
  static const Color brown = Color(0xFF271200);
  static const Color brown2 = Color(0xFF4A2800);
  static const Color brownMuted = Color(0x6B271200); // rgba(39, 18, 0, 0.42)
  static const Color brownLight = Color(0x0F271200); // rgba(39, 18, 0, 0.06)

  // ─── Background ───
  static const Color background = Color(0xFFFAFAFA);
  static const Color warmBg = Color(0xFFF5EFE6);
  static const Color cream = Color(0xFFFBF7F2);

  // ─── Lines / Borders ───
  static const Color line = Color(0xFFEBE1D6);
  static const Color lineLight = Color(0x80EBE1D6);

  // ─── Semantic ───
  static const Color success = Color(0xFF1A7A38);
  static const Color successLight = Color(0x101A7A38);
  static const Color danger = Color(0xFFC0001A);
  static const Color dangerLight = Color(0x10C0001A);
  static const Color warning = Color(0xFFB45309);
  static const Color warningLight = Color(0x10B45309);

  // ─── Overlays ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ─── Shadows ───
  static const Color shadowSoft = Color(0x0A271200);
  static const Color shadowPremium = Color(0x14271800);
  static const Color shadowGlow = Color(0x40E8560A);

  // ─── Gradients ───
  static const Gradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, Color(0xFFF97316)],
  );

  static const Gradient orangeRadial = RadialGradient(
    colors: [Color(0x26FFFFFF), Color(0x00000000)],
    radius: 0.6,
  );

  static const Gradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, Color(0xFFC44008), Color(0xFFF4732A)],
  );
}
