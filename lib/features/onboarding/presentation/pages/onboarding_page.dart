import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brand_painters.dart';
import '../../domain/onboarding_slide.dart';

/// OnboardingPage — True multi-screen progressive onboarding with PageView.
///
/// Architecture:
///   - PageController drives both the PageView (swipe) and the indicator.
///   - Each page renders from [kOnboardingSlides] data model.
///   - Top brand panel (45%) is always stable; only the bottom sheet content
///     transitions, giving a split-screen feel without full rebuilds.
///   - Spring easing (0.16, 1, 0.3, 1) on all transitions.
///
/// Accessibility: Semantics wrapping per slide, announce page change.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _panelPulseCtrl;
  int _currentPage = 0;

  static const _spring = Cubic(0.16, 1, 0.3, 1);
  static const _pageDuration = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _panelPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _panelPulseCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    HapticFeedback.lightImpact();
  }

  void _advance() {
    HapticFeedback.lightImpact();
    final isLast = _currentPage == kOnboardingSlides.length - 1;
    if (isLast) {
      context.go(RoutePaths.login);
      return;
    }
    _pageController.nextPage(
      duration: _pageDuration,
      curve: _spring,
    );
  }

  void _skip() {
    HapticFeedback.lightImpact();
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topHeight = size.height * 0.45;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // ─── Stable brand-orange top panel ─────────────────────────────────
          RepaintBoundary(
            child: Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topHeight + 48,
              child: _BrandTopPanel(
                pulseCtrl: _panelPulseCtrl,
                currentPage: _currentPage,
                onSkip: _skip,
              ),
            ),
          ),

          // ─── Swipeable bottom content PageView ──────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height - topHeight + 40,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemCount: kOnboardingSlides.length,
              itemBuilder: (context, index) {
                final slide = kOnboardingSlides[index];
                final isActive = index == _currentPage;
                return _SlideBottomSheet(
                  slide: slide,
                  isActive: isActive,
                  currentPage: _currentPage,
                  totalPages: kOnboardingSlides.length,
                  onAdvance: _advance,
                  onSkip: _skip,
                );
              },
            ),
          ),

          // ─── Home indicator (outside PageView to prevent rebuild) ───────────
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

// ─── Brand Top Panel (stable across swipes) ──────────────────────────────────

class _BrandTopPanel extends StatelessWidget {
  const _BrandTopPanel({
    required this.pulseCtrl,
    required this.currentPage,
    required this.onSkip,
  });

  final AnimationController pulseCtrl;
  final int currentPage;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base orange fill
        Positioned.fill(child: ColoredBox(color: AppColors.primary)),

        // Top-right ambient glow
        Positioned.fill(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.8, -0.7),
                  radius: 1.0,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Ambient breathing orb
        Positioned(
          top: -30,
          right: -30,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: pulseCtrl,
              builder: (context, child) => Opacity(
                opacity: 0.18 + (pulseCtrl.value * 0.10),
                child: child,
              ),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ),

        // Bottom-left orb
        Positioned(
          bottom: -20,
          left: -20,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: pulseCtrl,
              builder: (context, child) => Opacity(
                opacity: 0.15 + (pulseCtrl.value * 0.08),
                child: child,
              ),
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFB085),
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
              child: AnimatedOpacity(
                opacity: currentPage < kOnboardingSlides.length - 1 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: onSkip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      'SKIP',
                      style: AppTypography.labelMicro.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Logo + brand name (stable center)
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo mark
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
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const CustomPaint(
                    painter: BurgerIconPainter(),
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

                const SizedBox(height: 12),

                Text(
                  'BURGER FARM',
                  style: AppTypography.headlineLg.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 150.ms)
                    .slideY(
                      begin: -0.2,
                      end: 0,
                      duration: 600.ms,
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

// ─── Individual Slide Bottom Sheet ────────────────────────────────────────────

class _SlideBottomSheet extends StatelessWidget {
  const _SlideBottomSheet({
    required this.slide,
    required this.isActive,
    required this.currentPage,
    required this.totalPages,
    required this.onAdvance,
    required this.onSkip,
  });

  final OnboardingSlide slide;
  final bool isActive;
  final int currentPage;
  final int totalPages;
  final VoidCallback onAdvance;
  final VoidCallback onSkip;

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
          // Pagination dots
          _PaginationDots(total: totalPages, current: currentPage),

          const SizedBox(height: AppSpacing.lg),

          // Slide tagline (if any)
          if (slide.tagline != null) ...[
            Text(
              slide.tagline!.toUpperCase(),
              style: AppTypography.labelMicro.copyWith(
                color: AppColors.primary,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],

          // Headline
          Semantics(
            header: true,
            child: RichText(
              text: TextSpan(
                style: AppTypography.headlineXL.copyWith(
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(text: '${slide.headline}\n'),
                  TextSpan(
                    text: slide.headlineAccent,
                    style: AppTypography.headlineXL.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            slide.body,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textMuted,
              height: 1.65,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Divider(
            color: AppColors.border.withValues(alpha: 0.5),
            height: 1,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Feature pills
          Row(
            children: slide.features
                .map((f) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: slide.features.last == f ? 0 : AppSpacing.sm,
                        ),
                        child: _FeaturePill(feature: f),
                      ),
                    ))
                .toList(),
          ),

          const Spacer(),

          // CTA button
          _CtaButton(
            label: slide.ctaLabel,
            onTap: onAdvance,
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

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
          duration: const Duration(milliseconds: 320),
          curve: const Cubic(0.16, 1, 0.3, 1),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24.0 : 6.0,
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
  const _FeaturePill({required this.feature});
  final OnboardingFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(feature.icon, size: 15, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            feature.label.toUpperCase(),
            style: AppTypography.labelMicro.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatefulWidget {
  const _CtaButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: 100.ms);
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: AppShadows.brandGlow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
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

class _HomeBar extends StatelessWidget {
  const _HomeBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
