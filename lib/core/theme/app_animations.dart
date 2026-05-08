import 'package:flutter/material.dart';

/// Animation constants that mirror GSAP easing used in the HTML prototypes.
/// spring ≈ cubic-bezier(0.16, 1, 0.3, 1)
class AppAnimations {
  AppAnimations._();

  // ── Curves ─────────────────────────────────────────────
  static const Curve spring  = Cubic(0.16, 1, 0.3, 1);
  static const Curve expoOut = Cubic(0.16, 1, 0.3, 1);
  static const Curve backOut = Curves.easeOutBack;

  // ── Durations ──────────────────────────────────────────
  static const Duration fast     = Duration(milliseconds: 200);
  static const Duration normal   = Duration(milliseconds: 300);
  static const Duration slow     = Duration(milliseconds: 500);
  static const Duration entrance = Duration(milliseconds: 800);

  // ── Stagger ────────────────────────────────────────────
  static const Duration staggerItem = Duration(milliseconds: 100);

  /// Fade-up helper used across multiple screens.
  /// Uses [Transform.translate] with pixel offsets (NOT fractional).
  static Widget fadeUp({
    required Widget child,
    required Animation<double> animation,
    double startY = 20,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, startY * (1 - animation.value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
