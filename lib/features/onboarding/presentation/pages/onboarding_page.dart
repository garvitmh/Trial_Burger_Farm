import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../shared/widgets/brand_painters.dart';

/// OnboardingPage — Premium split-layout onboarding experience.
///
/// Layout: Brand-orange top panel (45%) + white bottom sheet (55%).
/// The bottom sheet slides up with spring easing on mount.
/// Features: brand logo, headline, feature pills, CTA, Skip button.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _navigateToLogin() => context.go(RoutePaths.login);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topHeight = size.height * 0.45;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // ─── Top Brand Panel ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topHeight + 48, // extend slightly under the sheet
            child: _TopBrandPanel(onSkip: _navigateToLogin),
          ),

          // ─── Bottom Sheet (slides up) ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height - topHeight + 40,
            child: _BottomSheet(onGetStarted: _navigateToLogin)
                .animate()
                .slideY(
                  begin: 0.15,
                  end: 0,
                  duration: 700.ms,
                  curve: const Cubic(0.16, 1, 0.3, 1),
                )
                .fadeIn(duration: 500.ms),
          ),

          // Home indicator
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _HomeIndicator(dark: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBrandPanel extends StatefulWidget {
  const _TopBrandPanel({required this.onSkip});
  final VoidCallback onSkip;

  @override
  State<_TopBrandPanel> createState() => _TopBrandPanelState();
}

class _TopBrandPanelState extends State<_TopBrandPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid orange fill
        Container(color: AppColors.primary),

        // Radial glow top-right
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.7),
                radius: 1.0,
                colors: [
                  Colors.white.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Ambient orb bottom-left
        Positioned(
          bottom: -20,
          left: -20,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) => Opacity(
              opacity: 0.20 + (_pulseCtrl.value * 0.08),
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFB085),
                ),
              ),
            ),
          ),
        ),

        // Ambient orb top-right
        Positioned(
          top: -20,
          right: -20,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) => Opacity(
              opacity: 0.25 + (_pulseCtrl.value * 0.10),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ),

        // Skip button
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 20),
              child: TextButton(
                onPressed: widget.onSkip,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white.withValues(alpha: 0.90),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  'SKIP',
                  style: AppTypography.labelMicro.copyWith(
                    color: Colors.white.withValues(alpha: 0.90),
                    letterSpacing: 2.5,
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
            ),
          ),
        ),

        // Logo + brand name
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glassmorphism logo container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const CustomPaint(
                    painter: BurgerIconPainter(),
                    size: Size(32, 32),
                    child: SizedBox(width: 32, height: 32),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 700.ms,
                      curve: const Cubic(0.16, 1, 0.3, 1),
                    )
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 14),

                Text(
                  'BURGER FARM',
                  style: AppTypography.headlineLg.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 150.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 700.ms,
                      curve: const Cubic(0.16, 1, 0.3, 1),
                    )
                    .fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        boxShadow: AppShadows.float,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.xl,
        AppSpacing.pageH,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill indicator dots
          _PaginationDots(total: 3, current: 0)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: AppSpacing.lg),

          // Headline
          RichText(
            text: TextSpan(
              style: AppTypography.headlineXL.copyWith(
                color: AppColors.textPrimary,
              ),
              children: [
                const TextSpan(text: 'Real Burgers.\n'),
                TextSpan(
                  text: 'Real Fast.',
                  style: AppTypography.headlineXL.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: 300.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                curve: const Cubic(0.16, 1, 0.3, 1),
              )
              .fadeIn(duration: 500.ms),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Farm-fresh ingredients. Made to order.\nDelivered while it\'s still sizzling.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textMuted,
              height: 1.6,
            ),
          )
              .animate(delay: 380.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppSpacing.lg),

          // Divider
          Divider(color: AppColors.border.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Feature pills row
          Row(
            children: [
              _FeaturePill(
                icon: Icons.eco_rounded,
                label: 'Farm Fresh',
                delay: 450.ms,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FeaturePill(
                icon: Icons.timer_rounded,
                label: '18 Min Avg',
                delay: 530.ms,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FeaturePill(
                icon: Icons.local_shipping_rounded,
                label: 'Free ₹199+',
                delay: 610.ms,
              ),
            ],
          ),

          const Spacer(),

          // CTA Button
          _GetStartedButton(onTap: onGetStarted)
              .animate(delay: 700.ms)
              .slideY(begin: 0.3, end: 0, duration: 500.ms)
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _PaginationDots extends StatelessWidget {
  const _PaginationDots({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.delay,
  });
  final IconData icon;
  final String label;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: AppTypography.labelMicro.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate(delay: delay).fadeIn(duration: 400.ms).slideY(
            begin: 0.15,
            end: 0,
            duration: 400.ms,
            curve: const Cubic(0.16, 1, 0.3, 1),
          ),
    );
  }
}

class _GetStartedButton extends StatefulWidget {
  const _GetStartedButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: AppShadows.brandGlow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Grab Your Meal',
                style: AppTypography.buttonLabel.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      height: 5,
      decoration: BoxDecoration(
        color: dark
            ? AppColors.textPrimary.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
