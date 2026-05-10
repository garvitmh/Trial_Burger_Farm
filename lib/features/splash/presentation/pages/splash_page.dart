import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/bootstrap/app_initializer.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/brand_painters.dart';

/// SplashPage — Burger Farm premium splash screen.
///
/// LIFECYCLE:
///   1. Page mounts, starts entrance animations in sequence.
///   2. AppInitializer.initialize() runs in parallel.
///   3. A minimum display duration (1.8s) is respected for brand presence.
///   4. Once BOTH init is done AND minimum time has passed, bootstrap completes.
///   5. Router is notified, redirect logic runs, and routing proceeds.
///
/// NEVER rerenders after login. The GoRouter guard prevents re-entry.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  // Controls the arc progress animation.
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  static const Duration _minDisplayDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _arcAnimation = CurvedAnimation(
      parent: _arcController,
      curve: Curves.easeInOut,
    );

    // Set immersive status bar to match the brand orange background.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _runBootstrap();

    // Non-blocking: precache after first frame so it doesn't delay render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppInitializer.precacheAssets(context);
    });
  }

  Future<void> _runBootstrap() async {
    // Start arc animation immediately
    _arcController.forward();

    // Run init and minimum timer in parallel.
    await Future.wait([
      AppInitializer.initialize(ref),
      Future.delayed(_minDisplayDuration),
    ]);

    // Signal bootstrap complete — router will now evaluate redirect.
    if (mounted) {
      ref.read(bootstrapCompleteProvider.notifier).complete();
    }
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Ambient Radial Glow (top-right) ─────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.6),
                  radius: 1.2,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ─── Ambient Radial Glow (bottom-left) ───────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.7, 0.8),
                  radius: 1.0,
                  colors: [
                    AppColors.primaryDark.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ─── Floating Ambient Orb 1 (RepaintBoundary isolated) ───────────
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.2,
            left: MediaQuery.sizeOf(context).width * 0.1,
            child: RepaintBoundary(
              child: _AmbientOrb(
                size: 220,
                color: const Color(0xFFFFB085),
                duration: const Duration(seconds: 4),
              ),
            ),
          ),

          // ─── Floating Ambient Orb 2 (RepaintBoundary isolated) ───────────
          Positioned(
            bottom: MediaQuery.sizeOf(context).height * 0.2,
            right: MediaQuery.sizeOf(context).width * 0.1,
            child: RepaintBoundary(
              child: _AmbientOrb(
                size: 260,
                color: AppColors.primaryDark,
                opacity: 0.30,
                duration: const Duration(seconds: 6),
              ),
            ),
          ),

          // ─── Center Content ───────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glassmorphism logo mark + pulse rings (isolated repaint)
                RepaintBoundary(
                  child: _LogoMark()
                      .animate()
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                        duration: 900.ms,
                        curve: const Cubic(0.16, 1, 0.3, 1),
                        delay: 100.ms,
                      )
                      .fadeIn(duration: 600.ms, delay: 100.ms),
                ),

                const SizedBox(height: 32),

                // "BURGER\nFARM" — Montreux Black display heading
                Text(
                  'BURGER\nFARM',
                  textAlign: TextAlign.center,
                  style: AppTypography.displaySplash.copyWith(
                    color: Colors.white,
                    height: 0.88,
                    letterSpacing: -1.5,
                    shadows: [
                      Shadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.4,
                      end: 0,
                      duration: 1000.ms,
                      curve: const Cubic(0.16, 1, 0.3, 1),
                      delay: 200.ms,
                    )
                    .fadeIn(duration: 700.ms, delay: 200.ms),

                const SizedBox(height: 20),

                // Decorative wave SVG
                _DecorativeWave()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .scaleX(
                      begin: 0,
                      end: 1,
                      duration: 600.ms,
                      curve: const Cubic(0.16, 1, 0.3, 1),
                      delay: 500.ms,
                    ),

                const SizedBox(height: 16),

                // "Farm-Fresh. Always." subtitle
                Text(
                  'Farm-Fresh. Always.',
                  style: AppTypography.displayTagline.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 900.ms,
                      curve: const Cubic(0.16, 1, 0.3, 1),
                      delay: 450.ms,
                    )
                    .fadeIn(duration: 600.ms, delay: 450.ms),
              ],
            ),
          ),

          // ─── Bottom Arc Progress + "Tap to continue" ─────────────────────
          Align(
            alignment: const Alignment(0, 0.82),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Arc progress drawn from the animation controller
                AnimatedBuilder(
                  animation: _arcAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 160,
                      height: 80,
                      child: CustomPaint(
                        painter: ArcProgressPainter(
                          progress: _arcAnimation.value,
                          opacity: 0.55,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'TAP TO CONTINUE',
                  style: AppTypography.labelMicro.copyWith(
                    color: Colors.white.withValues(alpha: 0.50),
                    letterSpacing: 3.5,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate(delay: 1400.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),

          // ─── Home Indicator Line ──────────────────────────────────────────
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _HomeIndicator(),
            ),
          ),

          // ─── Tap to advance (after init is done) ─────────────────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // Allow early tap to proceed once bootstrap is complete
                final isComplete = ref.read(bootstrapCompleteProvider);
                if (isComplete && mounted) {
                  context.go(RoutePaths.onboarding);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _LogoMark extends StatefulWidget {
  const _LogoMark();
  @override
  State<_LogoMark> createState() => _LogoMarkState();
}

class _LogoMarkState extends State<_LogoMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: const Cubic(0.215, 0.61, 0.355, 1),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring 1
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Opacity(
              opacity: (1 - _pulseAnimation.value).clamp(0.0, 0.5),
              child: Transform.scale(
                scale: 0.8 + (_pulseAnimation.value * 0.7),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Pulse ring 2 — offset by 1s
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final delayed = (_pulseController.value + 0.5) % 1.0;
              final curve = const Cubic(0.215, 0.61, 0.355, 1).transform(delayed);
              return Opacity(
                opacity: (1 - curve).clamp(0.0, 0.35),
                child: Transform.scale(
                  scale: 0.8 + (curve * 0.7),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Glassmorphism container
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.20),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomPaint(
              painter: const BurgerIconPainter(),
              size: const Size(56, 56),
              child: const SizedBox(width: 56, height: 56),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeWave extends StatelessWidget {
  const _DecorativeWave();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavePainter(),
      size: const Size(96, 12),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.80)
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
      size.width * 0.38, size.height,
      size.width * 0.50, size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.62, 0,
      size.width * 0.75, size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.88, size.height,
      size.width, size.height / 2,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}

class _AmbientOrb extends StatefulWidget {
  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.duration,
    this.opacity = 0.20,
  });

  final double size;
  final Color color;
  final Duration duration;
  final double opacity;

  @override
  State<_AmbientOrb> createState() => _AmbientOrbState();
}

class _AmbientOrbState extends State<_AmbientOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Opacity(
        opacity: widget.opacity * (0.7 + (_anim.value * 0.3)),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
