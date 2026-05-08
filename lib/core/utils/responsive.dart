import 'package:flutter/material.dart';

/// Responsive utilities that enforce the mobile-first 400px design width.
/// Mirrors the HTML's max-w-[400px] with centered layout behaviour.
class Responsive {
  static const double designWidth  = 400;
  static const double designHeight = 850;

  /// Constrained width matching the HTML max-w-[400px] behaviour.
  static double contentWidth(BuildContext context) =>
      MediaQuery.of(context).size.width.clamp(0, designWidth);

  /// Scale factor relative to design width.
  static double scale(BuildContext context) =>
      contentWidth(context) / designWidth;

  /// Responsive symmetric padding.
  static EdgeInsets symmetric({
    BuildContext? context,
    double horizontal = 24,
    double vertical = 0,
  }) {
    final s = context != null ? scale(context) : 1.0;
    return EdgeInsets.symmetric(
      horizontal: horizontal * s,
      vertical: vertical * s,
    );
  }

  /// Safe area + clamped side insets.
  static EdgeInsets safePadding(BuildContext context) {
    final mq = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mq.padding.top,
      bottom: mq.padding.bottom,
      left: mq.padding.left.clamp(0, 16),
      right: mq.padding.right.clamp(0, 16),
    );
  }
}
