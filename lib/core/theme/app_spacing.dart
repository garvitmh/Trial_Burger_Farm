

/// AppSpacing — Burger Farm Design System Spacing Tokens
///
/// Strict base-8 spacing system. All padding, margin, and gap values in
/// the application MUST reference these named constants only.
/// Hardcoded numeric spacing in widgets is a FORBIDDEN PATTERN.
abstract final class AppSpacing {
  // ─── Base Scale (multiples of 4, anchored at 8) ──────────────────────
  static const double xs2 = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 28.0;
  static const double xl4 = 32.0;
  static const double xl5 = 40.0;
  static const double xl6 = 48.0;
  static const double xl7 = 56.0;
  static const double xl8 = 64.0;
  static const double xl9 = 72.0;
  static const double xl10 = 88.0;

  // ─── Semantic Aliases ───────────────────────────────────────────────────
  // Aligned to CSS reference (padding: 56px 24px 88px in body)
  static const double pageHorizontal = xl2;     // 24px — standard screen padding
  static const double pageVerticalTop = xl7;    // 56px — page top breathing room
  static const double pageVerticalBottom = xl10;// 88px — bottom safe nav padding

  static const double cardPadding = xl;         // 20px — internal card padding
  static const double sectionGap = xl6;         // 48px — between major sections
  static const double itemGap = xl2;            // 24px — between list items
  static const double inlineGap = sm;           // 8px  — inline element gap

  // Shorthand aliases used in UI pages
  static const double pageH = pageHorizontal;   // 24px — horizontal screen padding
  static const double xxl = xl5;                // 40px — extra-extra large gap

  // ─── Component Heights ──────────────────────────────────────────────────
  static const double buttonHeight = 52.0;      // .btn height from CSS
  static const double buttonHeightSm = 50.0;    // .btn-ghost / .btn-outline
  static const double inputHeight = 52.0;       // .inp height from CSS
  static const double statusBarHeight = 52.0;   // .sb height from CSS
}
