import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';

/// LocationSetupPage — Location permission rationale and preparation screen.
///
/// Layout: Full brand-orange background with dot matrix grid pattern.
/// Features:
///   - Animated pulsing location pin with ripple rings
///   - Clear permission rationale copy
///   - Primary "Allow Location" CTA
///   - Ghost "Enter manually" fallback
///
/// Architecture is prepared for future nearest-store calculation once
/// store coordinate datasets are available.
class LocationSetupPage extends ConsumerStatefulWidget {
  const LocationSetupPage({super.key});

  @override
  ConsumerState<LocationSetupPage> createState() => _LocationSetupPageState();
}

class _LocationSetupPageState extends ConsumerState<LocationSetupPage>
    with TickerProviderStateMixin {
  late AnimationController _ripple1Ctrl;
  late AnimationController _ripple2Ctrl;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _ripple1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _ripple2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // Start ring 2 with a 600ms delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ripple2Ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ripple1Ctrl.dispose();
    _ripple2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);
    HapticFeedback.mediumImpact();

    // Architecture boundary: geolocator permission request goes here.
    // For now, simulate a brief permission UI delay then proceed.
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isRequesting = false);
      // Proceed to home — routing guard will handle post-location state
      context.go('${RoutePaths.shell}/${RoutePaths.home}');
    }
  }

  void _enterManually() {
    HapticFeedback.lightImpact();
    context.go('${RoutePaths.shell}/${RoutePaths.home}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // ─── Dot-matrix pattern overlay ───────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _DotMatrixPainter()),
          ),

          // ─── Top gradient ──────────────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5],
                ),
              ),
            ),
          ),

          // ─── Rotating ambient glow ─────────────────────────────────────────
          IgnorePointer(
            child: Center(
              child: const _RotatingGlow(),
            ),
          ),

          // ─── Main content ──────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Pulsing location pin
                  _AnimatedLocationPin(
                    ripple1: _ripple1Ctrl,
                    ripple2: _ripple2Ctrl,
                  ).animate().scale(
                        begin: const Offset(0.7, 0.7),
                        duration: 700.ms,
                        curve: const Cubic(0.16, 1, 0.3, 1),
                      ).fadeIn(duration: 500.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Headline
                  Text(
                    'Find your nearest\nBurger Farm',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineXL.copyWith(
                      color: Colors.white,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 600.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    "We'll show you the closest outlet\nand your estimated delivery time.",
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.6,
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),

          // ─── Bottom CTA sheet ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActions(
              isRequesting: _isRequesting,
              onAllowLocation: _requestLocation,
              onEnterManually: _enterManually,
            ).animate(delay: 450.ms)
                .slideY(begin: 0.25, end: 0, duration: 600.ms, curve: const Cubic(0.16, 1, 0.3, 1))
                .fadeIn(duration: 500.ms),
          ),

          // Home indicator
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _HomeBar(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedLocationPin extends StatelessWidget {
  const _AnimatedLocationPin({
    required this.ripple1,
    required this.ripple2,
  });
  final AnimationController ripple1;
  final AnimationController ripple2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple ring 1
          AnimatedBuilder(
            animation: ripple1,
            builder: (context, _) {
              final v = CurvedAnimation(
                parent: ripple1,
                curve: Curves.easeOut,
              ).value;
              return Opacity(
                opacity: (1 - v).clamp(0.0, 0.40),
                child: Transform.scale(
                  scale: 0.8 + v * 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Ripple ring 2 — 600ms delayed
          AnimatedBuilder(
            animation: ripple2,
            builder: (context, _) {
              final v = CurvedAnimation(
                parent: ripple2,
                curve: Curves.easeOut,
              ).value;
              return Opacity(
                opacity: (1 - v).clamp(0.0, 0.30),
                child: Transform.scale(
                  scale: 0.6 + v * 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Pin container
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: AppShadows.glowBrand,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isRequesting,
    required this.onAllowLocation,
    required this.onEnterManually,
  });
  final bool isRequesting;
  final Future<void> Function() onAllowLocation;
  final VoidCallback onEnterManually;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        bottomPad + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.0),
            AppColors.primary,
            AppColors.primary,
          ],
          stops: const [0, 0.3, 1],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary: Allow Location (white button)
          _AllowButton(
            isLoading: isRequesting,
            onTap: onAllowLocation,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Ghost: Enter manually
          GestureDetector(
            onTap: onEnterManually,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Enter manually',
                style: AppTypography.buttonLabel.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllowButton extends StatefulWidget {
  const _AllowButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final Future<void> Function() onTap;

  @override
  State<_AllowButton> createState() => _AllowButtonState();
}

class _AllowButtonState extends State<_AllowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 120.ms);
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 22, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Allow Location',
                      style: AppTypography.buttonLabel.copyWith(
                        color: AppColors.primary,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DotMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    const spacing = 32.0;
    const dotRadius = 2.0;
    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotMatrixPainter oldDelegate) => false;
}

class _RotatingGlow extends StatefulWidget {
  const _RotatingGlow();

  @override
  State<_RotatingGlow> createState() => _RotatingGlowState();
}

class _RotatingGlowState extends State<_RotatingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.rotate(
        angle: _ctrl.value * 6.28318,
        child: child,
      ),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.4,
        height: MediaQuery.sizeOf(context).width * 1.4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 0.8,
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBar extends StatelessWidget {
  const _HomeBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
