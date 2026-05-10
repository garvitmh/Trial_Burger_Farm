import 'package:flutter/material.dart';

/// AppTypography — Burger Farm Design System Typography Tokens
///
/// FONT FIDELITY DECLARATION:
/// ─────────────────────────────────────────────────────────────────────────
///  CSS Variable  │ Font Family     │ Role                │ Flutter Family
/// ───────────────┼─────────────────┼─────────────────────┼───────────────
///  --fu           │ Recoleta        │ Primary UI Font      │ 'Recoleta'
///  --fd           │ Montreux Classic│ Display/Brand Font   │ 'MontreuxClassic'
/// ─────────────────────────────────────────────────────────────────────────
///
/// TYPOGRAPHY HIERARCHY (derived from CSS analysis):
///  - Display/Splash:   MontreuxClassic, 54px, w900, ls: -0.03em  (.sp-word)
///  - Brand Label:      MontreuxClassic, 14px, w800, ls: 0.11em   (.ob-brand)
///  - Page Title:       MontreuxClassic, 24px, w800, ls: 0.07em   (.ph-t)
///  - Section Header:   MontreuxClassic, 38px, w900, ls: -0.025em (.ob-h)
///  - Login Header:     MontreuxClassic, 22px, w800               (.lg-h)
///  - Body Text:        Recoleta,        13.5px, normal, lh: 1.65 (.ob-p)
///  - Button Label:     Recoleta,        15px, w700, ls: 0.01em   (.btn)
///  - Input Text:       Recoleta,        14px, w500               (.inp)
///  - Caption:          Recoleta,        11px, normal             (.lg-p)
///  - Label Micro:      Recoleta,        10px, w700, ls: 0.17em   (pill)
///  - Status Bar Time:  Recoleta,        15px, w700, ls: -0.02em  (.sb-t)
///
/// ⚠️ FONT WEIGHT LIMITATION:
///   MontreuxClassic: Only 'Regular' (400) weight OTF file is available.
///   CSS references w700/w800/w900 for Montreux Classic display text.
///   Flutter will use the single available weight for all Montreux declarations.
///   ACTION REQUIRED: Acquire Montreux Bold/Black weights from font vendor
///   for full brand fidelity on display text.

abstract final class AppTypography {
  // ─── Font Families ────────────────────────────────────────────────────────
  static const String fontDisplay = 'MontreuxClassic'; // --fd: branding/headers
  static const String fontUI = 'Recoleta';             // --fu: body/UI elements

  // ─── TextStyles: DISPLAY (MontreuxClassic) ───────────────────────────────

  /// Splash wordmark — .sp-word (54px, w900, ls: -0.03em, lh: 0.95)
  static const TextStyle displaySplash = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 54,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.62, // -0.03em × 54
    height: 0.95,
    color: Color(0xFFFFFFFF),
  );

  /// Splash tagline — .sp-tag (20px, w400, italic, ls: 0.01em)
  static const TextStyle displayTagline = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.2,
    color: Color(0xE0FFFFFF),
  );

  /// Section header — .ob-h (38px, w900, ls: -0.025em, lh: 1.05)
  static const TextStyle headlineXL = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 38,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.95, // -0.025em × 38
    height: 1.05,
  );

  /// Page header pill title — .ph-t (24px, w800, ls: 0.07em)
  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.68, // 0.07em × 24
  );

  /// Card/sheet title — .lg-h (22px, w800)
  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  /// Brand label — .ob-brand / .lg-brand (14px, w800, ls: 0.11em)
  static const TextStyle brandLabel = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.54, // 0.11em × 14
    color: Color(0xFFFFFFFF),
  );

  /// Section label — .pf-lbl (Montreux, large section labels)
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // ─── TextStyles: UI (Recoleta) ────────────────────────────────────────────

  /// Button label — .btn (15px, w700, ls: 0.01em)
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontUI,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
  );

  /// Ghost/outline button — .btn-ghost / .btn-outline (14px, w600)
  static const TextStyle buttonLabelSm = TextStyle(
    fontFamily: fontUI,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Input text — .inp (14px, w500)
  static const TextStyle inputText = TextStyle(
    fontFamily: fontUI,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Input placeholder — .inp::placeholder (13px)
  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: fontUI,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  /// Body text — .ob-p (13.5px, normal, lh: 1.65)
  static const TextStyle body = TextStyle(
    fontFamily: fontUI,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );

  /// Body medium — general readable body
  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontUI,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Status bar time — .sb-t (15px, w700, ls: -0.02em)
  static const TextStyle statusTime = TextStyle(
    fontFamily: fontUI,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// Caption / subtitle — .lg-p / .lg-sub (12px)
  static const TextStyle caption = TextStyle(
    fontFamily: fontUI,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// Caption medium — .lg-trust (11px, w500)
  static const TextStyle captionMd = TextStyle(
    fontFamily: fontUI,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  /// Micro label — .ph-pill / .rl (10px, w700, ls: 0.17-0.18em, uppercase)
  static const TextStyle labelMicro = TextStyle(
    fontFamily: fontUI,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.7,
  );

  /// Skip / ghost link text — .ob-skip (12px, w600)
  static const TextStyle labelAction = TextStyle(
    fontFamily: fontUI,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// Chip label — .chip-t (12px, w600)
  static const TextStyle chip = TextStyle(
    fontFamily: fontUI,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// Badge text — .badge (10px, w700)
  static const TextStyle badge = TextStyle(
    fontFamily: fontUI,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  /// Hint / legal — .sp-hint / .lg-terms (10-10.5px, muted)
  static const TextStyle hint = TextStyle(
    fontFamily: fontUI,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );
}
