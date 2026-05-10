/// AppRadius — Burger Farm Design System Border Radius Tokens
///
/// Derived from CSS --r-* variables.
/// All border radius values MUST reference these tokens.
abstract final class AppRadius {
  // ─── Direct CSS Mapping ──────────────────────────────────────────────────
  static const double button = 100.0;  // --r-btn: 100px (pill)
  static const double input = 14.0;    // --r-input: 14px
  static const double card = 20.0;     // --r-card: 20px
  static const double sheet = 28.0;    // --r-sheet: 28px

  // ─── Semantic Aliases ────────────────────────────────────────────────────
  static const double pill = button;    // Full pill shape
  static const double xs = 6.0;         // Tight rounding (e.g. badge)
  static const double sm = 10.0;        // Small rounding
  static const double md = input;       // Standard component radius
  static const double lg = card;        // Card / large component
  static const double xl = sheet;       // Bottom sheets / modals
  static const double circle = 999.0;   // Perfect circle fallback
}
