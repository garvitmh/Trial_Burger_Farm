import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// AppAnimations — Burger Farm Motion & Animation Infrastructure
///
/// Centralizes all reusable animation presets using flutter_animate.
/// Widgets must compose from these presets rather than defining
/// inline animation logic (FORBIDDEN PATTERN per FORBIDDEN_PATTERNS.md).
///
/// Motion Philosophy (from animation_reference):
///  - Premium but restrained
///  - Fast perceived responsiveness (150–300ms core range)
///  - No over-animation
///  - Controllers must be properly disposed — use flutter_animate extensions
///  - Transitions defined globally in router, not per-widget

// ─── Timing Curves ─────────────────────────────────────────────────────────

/// Standard enterprise easing curves
abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutQuart;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve linear = Curves.linear;
}

// ─── flutter_animate Extension Presets ─────────────────────────────────────

/// Reusable Effect sequences to be applied via .animate() extension.
/// Usage:  Widget.animate().then(delay: ...).fadeIn(...)
///         or AppAnimations.fadeSlideUp applied via animate(effects: ...)
abstract final class AppAnimations {
  // ─── Fade Presets ──────────────────────────────────────────────────────

  /// Standard screen element fade-in (180ms)
  static List<Effect> fadeIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 180),
  }) =>
      [
        FadeEffect(
          delay: delay,
          duration: duration,
          curve: AppCurves.enter,
        ),
      ];

  // ─── Slide + Fade Presets ──────────────────────────────────────────────

  /// Upward entry: element slides up 16px while fading in (250ms)
  /// Used for: list items, content cards entering the viewport
  static List<Effect> fadeSlideUp({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 250),
  }) =>
      [
        FadeEffect(delay: delay, duration: duration, curve: AppCurves.enter),
        SlideEffect(
          delay: delay,
          duration: duration,
          curve: AppCurves.enter,
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ),
      ];

  /// Downward entry: slides down 12px while fading in
  /// Used for: dropdown menus, notification toasts
  static List<Effect> fadeSlideDown({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 220),
  }) =>
      [
        FadeEffect(delay: delay, duration: duration, curve: AppCurves.enter),
        SlideEffect(
          delay: delay,
          duration: duration,
          curve: AppCurves.enter,
          begin: const Offset(0, -0.04),
          end: Offset.zero,
        ),
      ];

  // ─── Scale Presets ─────────────────────────────────────────────────────

  /// Gentle scale-in: from 0.94 → 1.0 (for modals / bottom sheets)
  static List<Effect> scaleIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 280),
  }) =>
      [
        FadeEffect(delay: delay, duration: duration, curve: AppCurves.enter),
        ScaleEffect(
          delay: delay,
          duration: duration,
          curve: AppCurves.enter,
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
        ),
      ];

  /// Button press scale: 0.975x (matches CSS .btn:active { transform: scale(.975) })
  static List<Effect> buttonPress({
    Duration duration = const Duration(milliseconds: 120),
  }) =>
      [
        ScaleEffect(
          duration: duration,
          curve: AppCurves.decelerate,
          begin: const Offset(1, 1),
          end: const Offset(0.975, 0.975),
        ),
      ];

  // ─── Shimmer / Skeleton ───────────────────────────────────────────────

  /// Shimmer loading effect for skeleton loaders
  static List<Effect> shimmer({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 1200),
  }) =>
      [
        ShimmerEffect(
          delay: delay,
          duration: duration,
          color: const Color(0x33FFFFFF),
          curve: AppCurves.linear,
        ),
      ];

  // ─── Staggered List Entry ──────────────────────────────────────────────

  /// Generate staggered delay for list items.
  /// Usage: AppAnimations.staggerDelay(index: i)
  static Duration staggerDelay(
    int index, {
    Duration base = const Duration(milliseconds: 60),
  }) =>
      base * index;
}

// ─── Page Transition Builder ────────────────────────────────────────────────

/// Standard page transitions for GoRouter.
/// Apply in route builder via CustomTransitionPage.
abstract final class AppPageTransitions {
  /// Fade transition — default for most routes
  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: AppCurves.enter),
      child: child,
    );
  }

  /// Slide-up transition — for bottom sheets promoted to full pages
  static Widget slideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: AppCurves.enter)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppCurves.enter),
        child: child,
      ),
    );
  }

  /// Horizontal slide — for lateral navigation (onboarding steps)
  static Widget slideHorizontal(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: AppCurves.enter)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppCurves.enter),
        child: child,
      ),
    );
  }
}
