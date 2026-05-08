// ============================================================================
// DESIGN SYSTEM - TYPOGRAPHY
// Based on HTML font usage: Montreux Classic (display) + Recoleta (body)
// Uses Google Fonts fallbacks: Playfair Display (display) + DM Sans (body)
// ============================================================================
import 'package:flutter/material.dart';

abstract final class AppTypography {
  // ─── Font Families ───
  static const String displayFont = 'MontreuxClassic';
  static const String bodyFont = 'Recoleta';

  // ─── Display Styles (Montreux Classic - headlines, logos, CTAs) ───
  static const TextStyle display64 = TextStyle(
    fontFamily: displayFont,
    fontSize: 64,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.03,
    height: 0.85,
    color: Colors.white,
  );

  static const TextStyle display40 = TextStyle(
    fontFamily: displayFont,
    fontSize: 40,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.025,
    height: 1.05,
    color: Color(0xFF271200),
  );

  static const TextStyle display36 = TextStyle(
    fontFamily: displayFont,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.02,
    height: 1.1,
    color: Color(0xFF271200),
  );

  static const TextStyle display26 = TextStyle(
    fontFamily: displayFont,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.01,
    height: 1.15,
    color: Color(0xFF271200),
  );

  static const TextStyle display22 = TextStyle(
    fontFamily: displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.11,
    height: 1.2,
    color: Colors.white,
  );

  static const TextStyle display18 = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.3,
    color: Color(0xFF271200),
  );

  static const TextStyle display16 = TextStyle(
    fontFamily: displayFont,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.3,
    color: Color(0xFF271200),
  );

  // ─── Body Styles (Recoleta - body text, descriptions) ───
  static const TextStyle body20 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.02,
    height: 1.4,
    color: Color(0xFF271200),
  );

  static const TextStyle body17 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: Color(0xFF271200),
  );

  static const TextStyle body16 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: Color(0xFF271200),
  );

  static const TextStyle body15 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.65,
    color: Color(0x80271200),
  );

  static const TextStyle body14 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: Color(0xFF271200),
  );

  static const TextStyle body13 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Color(0x80271200),
  );

  static const TextStyle body12 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Color(0x80271200),
  );

  static const TextStyle body11 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: Color(0x80271200),
  );

  static const TextStyle body10 = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.2,
    color: Color(0x80271200),
  );

  // ─── Specialized Styles ───
  static const TextStyle tag = TextStyle(
    fontFamily: displayFont,
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.18,
    height: 1.0,
    color: Color(0xBFE8560A),
  );

  static const TextStyle button = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.01,
    height: 1.0,
    color: Colors.white,
  );

  static const TextStyle price = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1.0,
    color: Color(0xFF271200),
  );

  static const TextStyle input = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: Color(0xFF271200),
  );

  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Color(0x40271200),
  );

  static const TextStyle label = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.08,
    height: 1.2,
    color: Color(0x80271200),
  );

  static const TextStyle bottomNavLabel = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.02,
    height: 1.0,
  );

  static const TextStyle bottomNavLabelInactive = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: Color(0x80271200),
  );
}
