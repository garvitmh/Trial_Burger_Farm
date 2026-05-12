import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/bootstrap/app_initializer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';

/// SplashPage — plays the client-provided `logo-animation.mp4` while the
/// app boots, then yields control to the router.
///
/// Bootstrap contract:
///   - Never performs initialization itself; that lives in `main()`.
///   - Holds the user here until BOTH bootstrap is complete AND the video
///     has played for at least `AppDurations.splashMin` (2.5s) — so a
///     fast boot doesn't cut off the brand reveal awkwardly.
///   - If bootstrap is still pending after 6s, a subtle "Still loading…"
///     hint fades in so the user never sees a frozen screen.
///   - If the video asset fails to load, falls back to a static logo.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  VideoPlayerController? _controller;
  bool _videoReady = false;
  bool _videoFailed = false;
  bool _slowBootHint = false;

  @override
  void initState() {
    super.initState();
    // Splash bg is black (matches Next.js reference). Status bar + nav bar
    // need light icons over the dark frame.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    _initVideo();
    Future<void>.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      final done = ref.read(bootstrapCompleteProvider);
      if (!done) setState(() => _slowBootHint = true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppInitializer.precacheAssets(context);
      _precacheBrandAssets();
    });
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/videos/logo-animation.mp4',
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.setVolume(0);
      await controller.setLooping(false);
      await controller.play();
      setState(() => _videoReady = true);
    } catch (e, st) {
      debugPrint('[SplashPage] Video init failed: $e\n$st');
      if (!mounted) return;
      setState(() => _videoFailed = true);
    }
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
        // Splash must never block on asset cache failure.
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBg,
      body: Semantics(
        label: 'Burger Farm splash screen',
        child: SafeArea(
          child: Stack(
            children: [
              Center(child: _Hero(
                controller: _controller,
                ready: _videoReady,
                failed: _videoFailed,
              )),
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
}

class _Hero extends StatelessWidget {
  const _Hero({required this.controller, required this.ready, required this.failed});
  final VideoPlayerController? controller;
  final bool ready;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    if (failed || controller == null) {
      return _StaticFallback();
    }
    if (!ready) {
      // Pre-init: show static fallback so we never flash a black frame.
      return _StaticFallback();
    }
    final aspect = controller!.value.aspectRatio;
    // Constrain to a sensible max width so we don't stretch on tablets.
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final width = shortest.clamp(240.0, 360.0);
    return AspectRatio(
      aspectRatio: aspect == 0 ? 9 / 16 : aspect,
      child: SizedBox(
        width: width,
        child: VideoPlayer(controller!),
      ),
    );
  }
}

class _StaticFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final size = shortest.clamp(160.0, 240.0);
    return Image.asset(
      'assets/images/brand/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, e, s) => SizedBox(width: size, height: size),
    );
  }
}
