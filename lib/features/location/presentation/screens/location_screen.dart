// ============================================================================
// LOCATION PERMISSION SCREEN - Full orange with pin animation
// Matches: location.html pixel-perfect
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:burger_farm_app/app/router/app_router.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';
import 'package:burger_farm_app/core/widgets/brand_button.dart';

class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  void _allowLocation(BuildContext context) {
    context.go(AppRoute.outlet);
  }

  void _enterManually(BuildContext context) {
    context.go(AppRoute.address);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.brand,
      body: Stack(
        children: [
          // ─── Background Pattern ───
          Positioned.fill(
            child: CustomPaint(
              painter: _MapPatternPainter(),
            ),
          ),
          // ─── Top Glow ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.brandLight.withValues(alpha: 0.1),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ─── Spinning Radial Gradient ───
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: _SpinningGradient(),
          ),
          // ─── Center Content ───
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // ─── Animated Location Pin ───
                  _AnimatedLocationPin(),
                  const SizedBox(height: 48),
                  // ─── Typography ───
                  Text(
                    'Find your nearest',
                    style: AppTypography.display36.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Burger Farm',
                    style: AppTypography.display36.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "We'll show you the closest outlet and your estimated delivery time.",
                    style: AppTypography.body15.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  // ─── Buttons ───
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.25),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: BrandButton.secondary(
                      text: 'Allow Location',
                      icon: Icons.location_on,
                      height: 56,
                      onPressed: () => _allowLocation(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Material(
                      color: AppColors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _enterManually(context),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            'Enter manually',
                            style: AppTypography.body16.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // ─── Bottom Home Indicator ───
          Positioned(
            bottom: 8,
            left: MediaQuery.of(context).size.width * 0.3,
            right: MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Map Pattern Painter ───
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Spinning Gradient ───
class _SpinningGradient extends StatefulWidget {
  @override
  State<_SpinningGradient> createState() => _SpinningGradientState();
}

class _SpinningGradientState extends State<_SpinningGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: MediaQuery.of(context).size.width * 1.4,
        height: MediaQuery.of(context).size.height * 1.4,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.white.withValues(alpha: 0.12),
              AppColors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated Location Pin ───
class _AnimatedLocationPin extends StatefulWidget {
  @override
  State<_AnimatedLocationPin> createState() => _AnimatedLocationPinState();
}

class _AnimatedLocationPinState extends State<_AnimatedLocationPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple rings
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildRippleRing(_controller.value),
                  _buildRippleRing((_controller.value + 0.5) % 1.0),
                ],
              );
            },
          ),
          // Pin container
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.2),
              ),
              boxShadow: AppShadows.glow,
            ),
            child: Icon(
              Icons.location_on,
              size: 40,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRippleRing(double progress) {
    final scale = 0.8 + progress * 0.7;
    final opacity = 0.3 * (1 - progress);
    return Transform.scale(
      scale: scale,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: opacity),
            width: 1,
          ),
        ),
      ),
    );
  }
}
