import 'package:flutter/material.dart';

/// Reusable burger icon used on splash, onboarding, and login screens.
/// Drawn via CustomPaint to avoid asset dependencies.
class BurgerIcon extends StatelessWidget {
  final double size;
  final Color color;

  const BurgerIcon({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BurgerIconPainter(color: color),
    );
  }
}

class _BurgerIconPainter extends CustomPainter {
  final Color color;
  const _BurgerIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Bottom bun
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.20, size.height * 0.56,
            size.width * 0.60, size.height * 0.19),
        Radius.circular(size.width * 0.09),
      ),
      Paint()..color = color.withValues(alpha: 0.95),
    );
    // Patty
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.17, size.height * 0.46,
            size.width * 0.66, size.height * 0.12),
        Radius.circular(size.width * 0.06),
      ),
      Paint()..color = color.withValues(alpha: 0.70),
    );
    // Cheese/toppings
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.23, size.height * 0.38,
            size.width * 0.54, size.height * 0.10),
        Radius.circular(size.width * 0.05),
      ),
      Paint()..color = color.withValues(alpha: 0.90),
    );
    // Top bun
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.19, size.height * 0.29,
            size.width * 0.62, size.height * 0.10),
        Radius.circular(size.width * 0.05),
      ),
      Paint()..color = color.withValues(alpha: 0.50),
    );
  }

  @override
  bool shouldRepaint(covariant _BurgerIconPainter old) => old.color != color;
}
