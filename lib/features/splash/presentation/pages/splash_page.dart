import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/bootstrap/app_initializer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/burger_logo.dart';

/// SplashPage — Burger Farm splash, hand-rebuilt from `logo-animation.mp4`.
///
/// The reference is a 4.57s video where the brand logo assembles
/// layer-by-layer (bottom bun → patty → lettuce → top bun → wordmark →
/// ® badge + cheese peek → fade-out). This screen reconstructs the same
/// timeline natively via [BurgerLogo] + a single [AnimationController].
///
/// Bootstrap contract:
///   - This screen observes [bootstrapCompleteProvider]. It never performs
///     initialization itself; that lives in `main()`. The render is purely
///     a visual hold while the rest of the app warms up.
///   - When `bootstrapComplete && elapsed >= splashMin`, the screen stops
///     drawing the animation and the router redirect takes over.
///   - If bootstrap is still pending after 6 seconds, a subtle retry hint
///     fades in beneath the logo. The screen never gets stuck visibly idle.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _master;
  bool _slowBootHint = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _master = AnimationController(
      vsync: this,
      duration: AppDurations.splashTotal,
    )..forward();

    // After 6 seconds of waiting, surface a subtle hint so the user never
    // sits on a frozen-looking screen.
    Future<void>.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      final done = ref.read(bootstrapCompleteProvider);
      if (!done) setState(() => _slowBootHint = true);
    });

    // Precache marquee/preferences assets after first frame so the
    // onboarding/preferences screens don't decode on first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppInitializer.precacheAssets(context);
      _precacheBrandAssets();
    });
  }

  Future<void> _precacheBrandAssets() async {
    if (!mounted) return;
    const chips = [
      'assets/images/onboarding/chip-burger.png',
      'assets/images/onboarding/chip-fries.png',
      'assets/images/onboarding/chip-drink.png',
      'assets/images/onboarding/chip-wrap.png',
      'assets/images/onboarding/chip-box.png',
      'assets/images/onboarding/chip-shake.png',
      'assets/images/onboarding/chip-harvest.png',
      'assets/images/preferences/farmer-art.png',
      'assets/images/brand/logo.png',
    ];
    for (final path in chips) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {
        // Asset missing or already cached — splash must not block on this.
      }
    }
  }

  @override
  void dispose() {
    _master.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Semantics(
        label: 'Burger Farm splash screen',
        child: SafeArea(
          child: Stack(
            children: [
              // The hero logo, choreographed against the 4.57s timeline.
              Center(
                child: AnimatedBuilder(
                  animation: _master,
                  builder: (context, _) => BurgerLogo(
                    t: _master.value,
                    size: _logoSize(context),
                  ),
                ),
              ),
              // Bottom retry hint, only after a slow bootstrap.
              if (_slowBootHint)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36,
                  child: AnimatedOpacity(
                    duration: AppDurations.normal,
                    opacity: 1,
                    child: Text(
                      'Still loading…',
                      textAlign: TextAlign.center,
                      style: AppTypography.captionMd.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _logoSize(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    return shortest.clamp(240.0, 360.0);
  }
}
