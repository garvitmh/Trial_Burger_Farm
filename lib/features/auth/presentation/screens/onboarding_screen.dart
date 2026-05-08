// ============================================================================
// ONBOARDING SCREEN - Orange top, white bottom sheet
// Matches: onboarding.html pixel-perfect
// Features: dots, headline, features row, CTA button
// ============================================================================
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/brand_button.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(WidgetRef ref, BuildContext context) async {
    if (context.mounted) {
      context.go(AppRoute.login);
    }
  }

  Future<void> _skip(WidgetRef ref, BuildContext context) async {
    if (context.mounted) {
      context.go(AppRoute.preferences);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Top Orange Section ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.42,
            child: Container(
              color: AppColors.brand,
              child: Stack(
                children: [
                  // Radial glow bottom-left
                  Positioned(
                    bottom: -40,
                    left: -40,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.white.withOpacity(0.1),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Radial glow top-right
                  Positioned(
                    top: -60,
                    right: -30,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.white.withOpacity(0.08),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Floating orbs
                  Positioned(
                    top: screenHeight * 0.12,
                    left: MediaQuery.of(context).size.width * 0.15,
                    child: _FloatingOrb(
                      size: 160,
                      color: const Color(0xFFFFB085),
                      opacity: 0.2,
                      duration: const Duration(seconds: 4),
                    ),
                  ),
                  Positioned(
                    bottom: screenHeight * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: _FloatingOrb(
                      size: 190,
                      color: const Color(0xFFC94208),
                      opacity: 0.3,
                      duration: const Duration(seconds: 5),
                    ),
                  ),
                  // Skip button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 24,
                    child: GestureDetector(
                      onTap: () => _skip(ref, context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: AppTypography.body11.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Logo
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.2),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: const AppLogo(size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BURGER FARM',
                          style: AppTypography.display22.copyWith(
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ─── Bottom Sheet ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: screenHeight * 0.40,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: AppShadows.float,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 36, 32, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Dots ───
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.line,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.line,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // ─── Headline ───
                      Text(
                        'Real Burgers.',
                        style: AppTypography.display40,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Real Fast.',
                              style: AppTypography.display40.copyWith(
                                color: AppColors.brand,
                              ),
                            ),
                            WidgetSpan(
                              child: Container(
                                margin: const EdgeInsets.only(top: 2),
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.brand.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ─── Description ───
                      Text(
                        "Farm-fresh ingredients. Made to order. Delivered while it's still sizzling.",
                        style: AppTypography.body15,
                      ),
                      const SizedBox(height: 20),
                      // ─── Features Row ───
                      Row(
                        children: [
                          _FeatureCard(
                            icon: Icons.local_florist,
                            label: 'Farm Fresh',
                          ),
                          const SizedBox(width: 12),
                          _FeatureCard(
                            icon: Icons.access_time_filled,
                            label: '18 Min Avg',
                          ),
                          const SizedBox(width: 12),
                          _FeatureCard(
                            icon: Icons.delivery_dining,
                            label: 'Free ₹199+',
                          ),
                        ],
                      ),
                      const Spacer(),
                      // ─── CTA Button ───
                      BrandButton(
                        text: 'Grab Your Meal',
                        icon: Icons.arrow_forward,
                        onPressed: () => _completeOnboarding(ref, context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Orb ───
class _FloatingOrb extends StatefulWidget {
  final double size;
  final Color color;
  final double opacity;
  final Duration duration;

  const _FloatingOrb({
    required this.size,
    required this.color,
    required this.opacity,
    required this.duration,
  });

  @override
  State<_FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<_FloatingOrb>
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
          color: widget.color.withOpacity(
            widget.opacity * (0.6 + 0.4 * _controller.value),
          ),
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.size * 0.2, sigmaY: widget.size * 0.2),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Feature Card ───
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cream.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.brown.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brown.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
                border: Border.all(
                  color: AppColors.line.withOpacity(0.3),
                ),
              ),
              child: Icon(icon, size: 18, color: AppColors.brand),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.brown,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
