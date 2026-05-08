// ============================================================================
// DESIGN SYSTEM - DIMENSIONS, SPACING, RADIUS, SHADOWS
// Extracted from HTML/CSS for pixel-perfect implementation
// ============================================================================
import 'package:flutter/material.dart';

abstract final class AppDimensions {
  // ─── Screen Constraints (matches HTML max-w-[400px]) ───
  static const double maxContentWidth = 430;
  static const double mobileWidth = 400;

  // ─── App Bar ───
  static const double appBarHeight = 56;

  // ─── Bottom Navigation ───
  static const double bottomNavHeight = 84;
  static const double bottomNavPadding = 8;

  // ─── Spacing Scale (matches Tailwind spacing) ───
  static const double space0 = 0;
  static const double space1 = 4;
  static const double space1_5 = 6;
  static const double space2 = 8;
  static const double space2_5 = 10;
  static const double space3 = 12;
  static const double space3_5 = 14;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;
  static const double space20 = 80;

  // ─── Horizontal Screen Padding ───
  static const double screenPadding = 24;

  // ─── Border Radius Scale ───
  static const double radiusNone = 0;
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radius3xl = 28;
  static const double radius4xl = 32;
  static const double radiusFull = 100;

  // ─── Card Padding ───
  static const double cardPadding = 16;
  static const double cardGap = 12;

  // ─── Button Height ───
  static const double buttonHeight = 56;
  static const double buttonMinWidth = 120;

  // ─── Input Height ───
  static const double inputHeight = 56;

  // ─── Icon Sizes ───
  static const double iconXs = 14;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // ─── Category Item Size ───
  static const double categoryIconSize = 64;

  // ─── Food Card Image Size ───
  static const double foodCardImageSize = 112;
}

abstract final class AppShadows {
  // ─── Soft Shadow ───
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A271200),
      blurRadius: 24,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05271800),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // ─── Premium Shadow ───
  static const List<BoxShadow> premium = [
    BoxShadow(
      color: Color(0x14271800),
      blurRadius: 40,
      offset: Offset(0, 20),
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Color(0x0D271800),
      blurRadius: 3,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // ─── Glow Shadow (brand) ───
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x40E8560A),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // ─── Brand Glow Shadow ───
  static const List<BoxShadow> brandGlow = [
    BoxShadow(
      color: Color(0x66E8560A),
      blurRadius: 30,
      offset: Offset(0, 10),
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Color(0x33E8560A),
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // ─── Float Shadow (bottom sheet top) ───
  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x0A271200),
      blurRadius: 32,
      offset: Offset(0, -12),
      spreadRadius: 0,
    ),
  ];

  // ─── Inset Soft ───
  static const List<BoxShadow> insetSoft = [
    BoxShadow(
      color: Color(0x0A271200),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
      blurStyle: BlurStyle.inner,
    ),
  ];

  // ─── Card Shadow ───
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F271800),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A271800),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  // ─── Button Shadow ───
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x6BE8560A),
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // ─── Empty (no shadow) ───
  static const List<BoxShadow> none = [];
}

abstract final class AppAnimations {
  // ─── Durations ───
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // ─── Curves ───
  static const Curve spring = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.fastOutSlowIn;
}
