/// AppDurations — Burger Farm Motion Timing Constants
///
/// All animation durations MUST reference these tokens.
/// Hardcoded millisecond values in widget animations are a FORBIDDEN PATTERN.
/// Timing is calibrated for a premium but responsive feel.
abstract final class AppDurations {
  // ─── Micro-Interactions (snappy, sub-200ms) ─────────────────────────────
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 120);   // .btn transition
  static const Duration snappy = Duration(milliseconds: 150);

  // ─── Standard UI Transitions (150ms–300ms sweet spot) ───────────────────
  static const Duration standard = Duration(milliseconds: 180); // .inp focus
  static const Duration moderate = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 300);

  // ─── Page & Panel Transitions ────────────────────────────────────────────
  static const Duration page = Duration(milliseconds: 320);
  static const Duration sheet = Duration(milliseconds: 380);
  static const Duration drawer = Duration(milliseconds: 300);

  // ─── Ambient / Looping Animations ────────────────────────────────────────
  static const Duration float = Duration(milliseconds: 3200);  // .pf-ring float
  static const Duration splash = Duration(milliseconds: 1200); // sp-fill shimmer
  static const Duration pulse = Duration(milliseconds: 2000);

  // ─── Stagger Delays ──────────────────────────────────────────────────────
  static const Duration staggerSm = Duration(milliseconds: 60);
  static const Duration staggerMd = Duration(milliseconds: 100);
  static const Duration staggerLg = Duration(milliseconds: 150);
  static const Duration staggerOtp = Duration(milliseconds: 75);

  // ─── Reference-parity additions ─────────────────────────────────────────
  static const Duration blurFade = Duration(milliseconds: 550);
  static const Duration pulseRing = Duration(milliseconds: 2000);
  static const Duration verifyDelay = Duration(milliseconds: 700);
  static const Duration splashTotal = Duration(milliseconds: 4570); // logo-animation.mp4 length
  static const Duration splashMin = Duration(milliseconds: 2500);   // earliest acceptable advance
  static const Duration marqueeSlow = Duration(seconds: 40);
  static const Duration marqueeFast = Duration(seconds: 28);
  static const Duration marqueeBob = Duration(milliseconds: 2750);
  static const Duration heroMorph = Duration(milliseconds: 420);
  static const Duration panelEnter = Duration(milliseconds: 380);
  static const Duration otpEnter = Duration(milliseconds: 320);
  static const Duration otpSuccess = Duration(milliseconds: 550);
}
