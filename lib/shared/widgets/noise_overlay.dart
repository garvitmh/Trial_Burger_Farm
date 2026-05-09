import 'dart:math';
import 'package:flutter/material.dart';

/// Subtle noise texture overlay — replicates the premium SVG fractalNoise
/// from the HTML prototype (opacity: 0.025, baseFrequency: 0.65).
/// Uses a fixed seed so it looks identical across rebuilds.
class NoiseOverlay extends StatelessWidget {
  const NoiseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.025,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _NoisePainter(),
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.02);
    final rng = Random(42); // fixed seed → deterministic texture
    final count = (size.width * size.height * 0.08).toInt();
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
