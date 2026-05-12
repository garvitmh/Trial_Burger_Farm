import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// BurgerLogo — Flutter reconstruction of the brand logo as seen in
/// `logo-animation.mp4`. Each visual layer (top bun, lettuce, patty,
/// wordmark, cheese, bottom bun, registered badge) is drawn separately so
/// the splash sequence can choreograph their entries.
///
/// The widget receives a single normalized progress value [t] in [0, 1]
/// representing the master timeline (0 = video t=0, 1 = video t≈4.57s).
/// Progress-to-layer mapping mirrors the frame walkthrough:
///   t=0.00–0.11 : nothing visible
///   t=0.11–0.22 : bottom bun + brown stripe + lettuce wave assemble
///   t=0.22–0.33 : top bun pops in with sesame
///   t=0.33–0.44 : wordmark types in
///   t=0.44–0.55 : settled, all base layers present
///   t=0.55–0.77 : registered ® badge + cheese triangle peek fade in
///   t=0.77–1.00 : hold
class BurgerLogo extends StatelessWidget {
  const BurgerLogo({
    super.key,
    required this.t,
    this.size = 220,
  });

  /// Master timeline progress 0..1 mapping to the 4.57s animation.
  final double t;

  /// Logo display size in logical pixels (height of the full burger).
  final double size;

  @override
  Widget build(BuildContext context) {
    // The painter draws shapes; the wordmark text is rendered as a real
    // Text widget on top so font shaping uses Flutter's text engine directly
    // (rather than canvas glyph drawing) for sharper edges and accessibility.
    final wordmarkOpacity = _opacityWindow(t, 0.36, 0.50);
    final wordmarkBlur = _between(t, 0.36, 0.48); // 1→0 motion blur
    final cheeseOpacity = _opacityWindow(t, 0.58, 0.72);
    final regOpacity = _opacityWindow(t, 0.62, 0.74);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Burger geometry — all painted layers
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _BurgerLogoPainter(
                  t: t,
                  cheeseOpacity: cheeseOpacity,
                  regOpacity: regOpacity,
                ),
              ),
            ),
          ),
          // Wordmark overlay — bottom 60% of the logo zone
          Align(
            alignment: const Alignment(0, 0.32),
            child: Opacity(
              opacity: wordmarkOpacity,
              child: _WordmarkLayer(
                size: size,
                blurSigma: wordmarkBlur * 4.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns 0 before `start`, ramps linearly to 1 over (start, end), then 1.
  static double _opacityWindow(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  /// Returns 1 → 0 across (start, end).
  static double _between(double t, double start, double end) {
    if (t <= start) return 1;
    if (t >= end) return 0;
    return 1 - (t - start) / (end - start);
  }
}

class _WordmarkLayer extends StatelessWidget {
  const _WordmarkLayer({required this.size, required this.blurSigma});

  final double size;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'BURGER',
          style: AppTypography.splashWordmarkLg.copyWith(
            color: AppColors.logoPattyBrown,
            fontSize: size * 0.14,
          ),
        ),
        SizedBox(height: size * 0.005),
        Text(
          'FARM',
          style: AppTypography.splashWordmarkLg.copyWith(
            color: AppColors.primary,
            fontSize: size * 0.18,
          ),
        ),
      ],
    );
    if (blurSigma < 0.1) return body;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: body,
    );
  }
}

// Re-export to avoid pulling in dart:ui at the call site.
// ignore: implementation_imports
class _BurgerLogoPainter extends CustomPainter {
  _BurgerLogoPainter({
    required this.t,
    required this.cheeseOpacity,
    required this.regOpacity,
  });

  final double t;
  final double cheeseOpacity;
  final double regOpacity;

  // ─── Per-layer progress windows (normalized) ──────────────────────────────
  // Numbers below correspond to fractions of the 4.57s master timeline.
  static const _bottomBunStart = 0.11; // t≈0.5s — orange streak appears
  static const _bottomBunEnd = 0.22;   // t≈1.0s — bottom bun fully formed
  static const _pattyStart = 0.15;     // t≈0.7s
  static const _pattyEnd = 0.22;
  static const _lettuceStart = 0.18;
  static const _lettuceEnd = 0.22;
  static const _topBunStart = 0.22;    // t≈1.0s
  static const _topBunEnd = 0.33;      // t≈1.5s — top bun fully settled

  double _progress(double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Layout proportions are taken from the static logo.png + frame 2.5s.
    // The full burger is ~62% of the available canvas height and centered.
    final w = size.width;
    final h = size.height;

    // Burger bounding box (centered).
    final burgerW = w * 0.88;
    final burgerH = h * 0.78;
    final cx = w / 2;
    final cy = h / 2;
    final left = cx - burgerW / 2;
    final top = cy - burgerH / 2;

    // Layer heights as fractions of burgerH.
    final topBunH = burgerH * 0.36;     // semicircular dome
    final lettuceH = burgerH * 0.10;
    final pattyH = burgerH * 0.28;      // tall — hosts the wordmark
    final brownStripeH = burgerH * 0.04;
    final bottomBunH = burgerH * 0.18;

    // ── Bottom bun (drawn first; appears at t≈0.5s) ─────────────────────────
    final pBottomBun = _progress(_bottomBunStart, _bottomBunEnd);
    if (pBottomBun > 0) {
      _drawBottomBun(
        canvas,
        Rect.fromLTWH(
          left,
          top + burgerH - bottomBunH,
          burgerW,
          bottomBunH,
        ),
        pBottomBun,
      );
    }

    // ── Brown stripe (between patty and bottom bun) ────────────────────────
    final pPatty = _progress(_pattyStart, _pattyEnd);
    if (pPatty > 0) {
      final stripeRect = Rect.fromLTWH(
        left,
        top + burgerH - bottomBunH - brownStripeH,
        burgerW,
        brownStripeH,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(stripeRect, const Radius.circular(3)),
        Paint()
          ..color = AppColors.logoPattyBrown.withValues(alpha: pPatty)
          ..style = PaintingStyle.fill,
      );

      // Cheese peek — small yellow triangle pointing down, slightly off-center.
      if (cheeseOpacity > 0.01) {
        _drawCheesePeek(canvas, stripeRect, cheeseOpacity);
      }
    }

    // ── Patty (hosts the wordmark — wordmark is rendered above by Stack) ────
    if (pPatty > 0) {
      _drawPatty(
        canvas,
        Rect.fromLTWH(
          left,
          top + topBunH + lettuceH,
          burgerW,
          pattyH,
        ),
        pPatty,
      );
    }

    // ── Lettuce wave ───────────────────────────────────────────────────────
    final pLettuce = _progress(_lettuceStart, _lettuceEnd);
    if (pLettuce > 0) {
      _drawLettuce(
        canvas,
        Rect.fromLTWH(left, top + topBunH, burgerW, lettuceH * 1.3),
        pLettuce,
      );
    }

    // ── Top bun (last to enter, with a pop) ────────────────────────────────
    final pTopBun = _progress(_topBunStart, _topBunEnd);
    if (pTopBun > 0) {
      _drawTopBun(
        canvas,
        Rect.fromLTWH(left, top, burgerW, topBunH),
        pTopBun,
      );
    }

    // ── Registered ® badge ─────────────────────────────────────────────────
    if (regOpacity > 0.01) {
      _drawRegistered(canvas, Offset(left + burgerW - 6, top + topBunH * 0.55),
          regOpacity);
    }
  }

  void _drawBottomBun(Canvas canvas, Rect rect, double p) {
    // Bottom bun: rounded rectangle, narrower than top. Animates from a
    // horizontal stroke (p≈0) to its full rounded shape.
    final width = rect.width * (0.6 + 0.4 * p);
    final height = rect.height * (0.5 + 0.5 * p);
    final centerX = rect.center.dx;
    final centerY = rect.top + rect.height / 2;
    final bunRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );
    final rrect = RRect.fromRectAndCorners(
      bunRect,
      bottomLeft: const Radius.circular(40),
      bottomRight: const Radius.circular(40),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    );

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.logoBunOrange.withValues(alpha: p),
          AppColors.logoBunShade.withValues(alpha: p),
        ],
      ).createShader(bunRect);
    canvas.drawRRect(rrect, paint);
  }

  void _drawPatty(Canvas canvas, Rect rect, double p) {
    final paint = Paint()
      ..color = AppColors.logoPattyBrown.withValues(alpha: p)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
  }

  void _drawLettuce(Canvas canvas, Rect rect, double p) {
    // Green wavy strip. The wave drops below the rect and rises above
    // alternately to form rounded scallops.
    final paint = Paint()
      ..color = AppColors.logoLettuce.withValues(alpha: p)
      ..style = PaintingStyle.fill;
    final path = Path();
    final waves = 5;
    final waveW = rect.width / waves;
    final yMid = rect.top + rect.height / 2;
    final yBot = rect.bottom;
    path.moveTo(rect.left, yMid);
    for (int i = 0; i < waves; i++) {
      final startX = rect.left + i * waveW;
      final cpX = startX + waveW / 2;
      final endX = startX + waveW;
      // Up-down wave: top-of-arc above rect.top by 30% of height.
      path.quadraticBezierTo(
        cpX,
        rect.top - rect.height * 0.10,
        endX,
        yMid,
      );
    }
    path.lineTo(rect.right, yBot);
    path.lineTo(rect.left, yBot);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTopBun(Canvas canvas, Rect rect, double p) {
    // Top bun: a semi-elliptical dome with shading + sesame seeds.
    final width = rect.width * (0.7 + 0.3 * p);
    final height = rect.height * (0.7 + 0.3 * p);
    final domeRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.bottom - height / 2),
      width: width,
      height: height * 2,
    );

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
      rect.left, rect.top, rect.width, rect.height,
    ));

    // Base orange dome.
    canvas.drawOval(
      domeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.logoBunOrange,
            AppColors.logoBunShade,
          ],
        ).createShader(domeRect),
    );

    // Right-side shade darker.
    final shadeRect = Rect.fromLTWH(
      domeRect.center.dx,
      domeRect.top,
      domeRect.width / 2,
      domeRect.height,
    );
    canvas.drawOval(
      shadeRect.shift(Offset(-2, 0)),
      Paint()
        ..color = AppColors.logoBunShade.withValues(alpha: 0.55),
    );

    // Sesame seeds — three rows of small ellipses across the top half.
    final seedPaint = Paint()..color = AppColors.logoSesame;
    final seedRng = math.Random(7);
    final seedsTopY = rect.top + height * 0.22;
    final seedsBottomY = rect.top + height * 0.85;
    for (int i = 0; i < 14; i++) {
      final fx = seedRng.nextDouble();
      final fy = seedRng.nextDouble();
      final cx = rect.left + width * 0.15 + fx * width * 0.7;
      final cy = seedsTopY + fy * (seedsBottomY - seedsTopY);
      final rx = 5.5 + seedRng.nextDouble() * 1.2;
      final ry = 2.8 + seedRng.nextDouble() * 0.6;
      // Rotate slightly per-seed.
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate((seedRng.nextDouble() - 0.5) * 0.6);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        seedPaint..color = AppColors.logoSesame.withValues(alpha: p),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawCheesePeek(Canvas canvas, Rect stripeRect, double opacity) {
    // A small downward-pointing triangle of cheese peeking from under the
    // patty/stripe seam. Slightly off-center to the right (matches frame 3.5s).
    final cx = stripeRect.center.dx + stripeRect.width * 0.04;
    final topY = stripeRect.top;
    final triH = stripeRect.height * 3.0;
    final triHalfW = stripeRect.height * 1.6;
    final path = Path()
      ..moveTo(cx - triHalfW, topY)
      ..lineTo(cx + triHalfW, topY)
      ..lineTo(cx, topY + triH)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.logoCheese.withValues(alpha: opacity),
    );
  }

  void _drawRegistered(Canvas canvas, Offset center, double opacity) {
    final paint = Paint()
      ..color = AppColors.logoPattyBrown.withValues(alpha: 0.55 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 6, paint);
    // Tiny R.
    final tp = TextPainter(
      text: TextSpan(
        text: 'R',
        style: TextStyle(
          color: AppColors.logoPattyBrown.withValues(alpha: 0.55 * opacity),
          fontSize: 7,
          fontWeight: FontWeight.w800,
          fontFamily: AppTypography.fontDisplay,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(_BurgerLogoPainter old) =>
      old.t != t || old.cheeseOpacity != cheeseOpacity || old.regOpacity != regOpacity;
}
