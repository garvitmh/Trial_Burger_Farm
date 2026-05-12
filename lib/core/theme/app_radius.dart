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

  // ─── Reference-parity additions ─────────────────────────────────────────
  static const double inputLg = 18.0;   // preferences inputs `rounded-[18px]`
  static const double cellLg = 16.0;    // OTP cells `rounded-2xl`
  static const double nav = 32.0;       // bottom nav + outlet card `rounded-[32px]`
  static const double ctaLg = 20.0;     // primary CTAs `rounded-[20px]` (alias of card)
  static const double backChip = 16.0;  // round back-chip 32x32 → r=16
}
