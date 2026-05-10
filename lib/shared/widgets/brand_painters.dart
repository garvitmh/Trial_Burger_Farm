import 'package:flutter/material.dart';

/// _BurgerIconPainter — Draws the stacked burger SVG logo mark in white.
class BurgerIconPainter extends CustomPainter {
  const BurgerIconPainter({this.opacity = 1.0});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Scale factor for the 48x48 source viewbox
    final sx = size.width / 48;
    final sy = size.height / 48;

    // Bottom bun (rect x10 y27 w28 h9 rx4.5)
    paint.color = Colors.white.withValues(alpha: 0.95 * opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10 * sx, 27 * sy, 28 * sx, 9 * sy),
        Radius.circular(4.5 * sx),
      ),
      paint,
    );

    // Patty layer (rect x8 y22 w32 h6 rx3)
    paint.color = Colors.white.withValues(alpha: 0.70 * opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8 * sx, 22 * sy, 32 * sx, 6 * sy),
        Radius.circular(3 * sx),
      ),
      paint,
    );

    // Cheese/tomato (rect x11 y18 w26 h5 rx2.5)
    paint.color = Colors.white.withValues(alpha: 0.90 * opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(11 * sx, 18 * sy, 26 * sx, 5 * sy),
        Radius.circular(2.5 * sx),
      ),
      paint,
    );

    // Top bun (rect x9 y14 w30 h5 rx2.5)
    paint.color = Colors.white.withValues(alpha: 0.50 * opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(9 * sx, 14 * sy, 30 * sx, 5 * sy),
        Radius.circular(2.5 * sx),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(BurgerIconPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

/// _ArcProgressPainter — Draws the semicircular loading arc at the bottom.
///
/// Inspired by the splash.html orbit-path animation:
///   d="M10,70 A80,80 0 0,1 180,70"
/// We reconstruct this as a native arc painted from [sweepFraction] progress.
class ArcProgressPainter extends CustomPainter {
  const ArcProgressPainter({required this.progress, this.opacity = 0.6});
  final double progress; // 0.0 → 1.0
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = 180.0 * (3.14159 / 180.0); // π  (left)
    final sweepAngle = 180.0 * (3.14159 / 180.0) * progress; // 0 → π

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(ArcProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.opacity != opacity;
}
