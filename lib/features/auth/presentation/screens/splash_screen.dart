// ============================================================================
// SPLASH SCREEN - Orange background with logo, animation, loading bar
// Matches: splash.html pixel-perfect
// ============================================================================
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:burger_farm_app/app/router/app_router.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';
import 'package:burger_farm_app/core/widgets/app_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go(AppRoute.onboarding);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brand,
      body: Stack(
        children: [
          // ─── Background Gradients ───
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 1.2,
              height: MediaQuery.of(context).size.height * 1.2,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x26FFFFFF), Color(0x00000000)],
                  radius: 0.6,
                ),
              ),
            ),
          ),
          // ─── Floating Ambient Orbs ───
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.1,
            child: _AmbientOrb(
              size: 260,
              color: const Color(0xFFFFB085),
              opacity: 0.2,
              duration: const Duration(seconds: 4),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: MediaQuery.of(context).size.width * 0.1,
            child: _AmbientOrb(
              size: 290,
              color: const Color(0xFFC94208),
              opacity: 0.3,
              duration: const Duration(seconds: 6),
            ),
          ),
          // ─── Center Content ───
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─── Logo ───
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: AppColors.white.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const AppLogo(size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    // ─── Brand Name ───
                    const Text(
                      'BURGER',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 0.85,
                        letterSpacing: -2,
                      ),
                    ),
                    const Text(
                      'FARM',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 0.85,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ─── Decorative Wave ───
                    CustomPaint(
                      size: const Size(100, 12),
                      painter: _WavePainter(),
                    ),
                    const SizedBox(height: 12),
                    // ─── Tagline ───
                    Text(
                      'Farm-Fresh. Always.',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: AppColors.white.withValues(alpha: 0.95),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ─── Bottom Loading Bar ───
          Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: const _SplashOrbitLoader(),
          ),
          // ─── Bottom Indicator ───
          Positioned(
            bottom: 12,
            left: MediaQuery.of(context).size.width * 0.3,
            right: MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ambient Orb Widget ───
class _AmbientOrb extends StatefulWidget {
  final double size;
  final Color color;
  final double opacity;
  final Duration duration;

  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.opacity,
    required this.duration,
  });

  @override
  State<_AmbientOrb> createState() => _AmbientOrbState();
}

class _AmbientOrbState extends State<_AmbientOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 
            widget.opacity * (0.7 + 0.3 * _controller.value),
          ),
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.size * 0.2, sigmaY: widget.size * 0.2),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Wave Painter ───
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.12, 0,
      size.width * 0.25, size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.37, size.height,
      size.width * 0.5, size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.62, 0,
      size.width * 0.75, size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.87, size.height,
      size.width, size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Animated Loading Bar ───
class _AnimatedLoadingBar extends StatefulWidget {
  @override
  State<_AnimatedLoadingBar> createState() => _AnimatedLoadingBarState();
}

class _SplashOrbitLoader extends StatefulWidget {
  const _SplashOrbitLoader();

  @override
  State<_SplashOrbitLoader> createState() => _SplashOrbitLoaderState();
}

class _SplashOrbitLoaderState extends State<_SplashOrbitLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 88,
          child: AnimatedBuilder(
            animation: _orbit,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(child: _SemiArc()),
                  _orbitIcon(0.0, Icons.fastfood),
                  _orbitIcon(0.33, Icons.local_fire_department),
                  _orbitIcon(0.66, Icons.local_drink),
                  Positioned(
                    left: 72,
                    top: 44,
                    child: Transform.scale(
                      scale: 0.85 + 0.15 * math.sin(_orbit.value * math.pi * 2),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.26),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: 128, child: _AnimatedLoadingBar()),
        const SizedBox(height: 24),
        Text(
          'Tap to continue',
          style: AppTypography.body10.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _orbitIcon(double phase, IconData icon) {
    final t = (_orbit.value + phase) % 1.0;
    final angle = math.pi * (1.0 - t);
    final x = 100 + 90 * math.cos(angle);
    final y = 70 - 90 * math.sin(angle);

    return Positioned(
      left: x - 21,
      top: y - 21,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SemiArc extends StatelessWidget {
  const _SemiArc();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SemiArcPainter(),
    );
  }
}

class _SemiArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(10, 70)
      ..arcToPoint(
        const Offset(190, 70),
        radius: const Radius.circular(90),
        clockwise: false,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedLoadingBarState extends State<_AnimatedLoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.33,
            child: Transform.translate(
              offset: Offset(
                _slideAnimation.value * MediaQuery.of(context).size.width * 0.3,
                0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
