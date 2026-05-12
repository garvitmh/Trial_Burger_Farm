import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/blur_fade.dart';

/// Permission state for the location request flow.
enum _LocationStatus {
  idle,
  requesting,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  unavailable,
  timeout,
}

/// LocationSetupPage — rebuilt against the Next.js reference's "Share
/// Location" screen: concentric pulse rings + floating chip decorations +
/// brand-glow CTA.
///
/// Adds enterprise extras that the reference omits but are right for a
/// real product:
///   - AppLifecycleState listener so a return-from-Settings refreshes state.
///   - 15-second GPS acquisition timeout with retry CTA.
///   - Distinct UI for every permission failure path.
class LocationSetupPage extends ConsumerStatefulWidget {
  const LocationSetupPage({super.key});

  @override
  ConsumerState<LocationSetupPage> createState() => _LocationSetupPageState();
}

class _LocationSetupPageState extends ConsumerState<LocationSetupPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ring1;
  late final AnimationController _ring2;
  late final AnimationController _ring3;
  late final AnimationController _emojiBob;
  _LocationStatus _status = _LocationStatus.idle;
  String? _statusDetail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _ring1 = AnimationController(vsync: this, duration: AppDurations.pulseRing)
      ..repeat();
    _ring2 = AnimationController(vsync: this, duration: AppDurations.pulseRing);
    _ring3 = AnimationController(vsync: this, duration: AppDurations.pulseRing);
    _emojiBob = AnimationController(
      vsync: this,
      duration: AppDurations.marqueeBob,
    )..repeat(reverse: true);
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ring2.repeat();
    });
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) _ring3.repeat();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ring1.dispose();
    _ring2.dispose();
    _ring3.dispose();
    _emojiBob.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // User may have returned from device settings — re-evaluate permission.
    if (_status == _LocationStatus.deniedForever ||
        _status == _LocationStatus.serviceDisabled) {
      _refreshPermission();
    }
  }

  Future<void> _refreshPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setStatus(_LocationStatus.serviceDisabled,
          'Location services are turned off.\nEnable GPS in your device settings.');
      return;
    }
    final p = await Geolocator.checkPermission();
    if (p == LocationPermission.always || p == LocationPermission.whileInUse) {
      _onGranted();
    } else if (p == LocationPermission.deniedForever) {
      _setStatus(_LocationStatus.deniedForever,
          'Location is permanently denied. Open Settings to grant access.');
    } else {
      _setStatus(_LocationStatus.idle, null);
    }
  }

  void _setStatus(_LocationStatus s, String? detail) {
    if (!mounted) return;
    setState(() {
      _status = s;
      _statusDetail = detail;
    });
  }

  Future<void> _onShareLocation() async {
    if (_status == _LocationStatus.requesting) return;
    HapticFeedback.mediumImpact();
    _setStatus(_LocationStatus.requesting, null);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setStatus(_LocationStatus.serviceDisabled,
            'Location services are turned off.\nEnable GPS in your device settings.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          // Acquire a location with a strict 15s timeout so the user is
          // never stranded waiting for GPS to warm up.
          try {
            await Geolocator.getCurrentPosition().timeout(
              const Duration(seconds: 15),
            );
          } on TimeoutException {
            _setStatus(_LocationStatus.timeout,
                'Taking longer than expected to read GPS. Try again?');
            return;
          }
          _onGranted();
        case LocationPermission.denied:
          _setStatus(_LocationStatus.denied,
              'We need your location to find the nearest Burger Farm.');
        case LocationPermission.deniedForever:
          _setStatus(_LocationStatus.deniedForever,
              'Location is permanently denied. Open Settings to grant access.');
        case LocationPermission.unableToDetermine:
          _setStatus(_LocationStatus.unavailable,
              "We couldn't determine your location. Try entering it manually.");
      }
    } catch (e) {
      _setStatus(_LocationStatus.unavailable,
          'Could not access location services. Enter address manually?');
    }
  }

  void _onGranted() {
    HapticFeedback.lightImpact();
    _setStatus(_LocationStatus.granted, null);
    Future<void>.delayed(AppDurations.normal, () {
      if (!mounted) return;
      context.go('${RoutePaths.shell}/${RoutePaths.home}');
    });
  }

  void _onEnterManually() {
    HapticFeedback.lightImpact();
    context.push('${RoutePaths.locationSetup}/search');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl4,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              BlurFade(
                delay: const Duration(milliseconds: 100),
                child: _LocationIconBadge(),
              ),
              const SizedBox(height: AppSpacing.xl),
              BlurFade(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Find your closest\nBurger Farm',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayHeroLg.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              BlurFade(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  _statusDetail ??
                      'Share your location so we can show outlets near you, your menu, and accurate delivery times.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl4),
              Expanded(
                child: _PulseRadar(
                  ring1: _ring1,
                  ring2: _ring2,
                  ring3: _ring3,
                  emojiBob: _emojiBob,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              BlurFade(
                delay: const Duration(milliseconds: 700),
                child: _ShareLocationCta(
                  status: _status,
                  onShare: _onShareLocation,
                  onOpenSettings: () => Geolocator.openAppSettings(),
                  onOpenLocationSettings: () =>
                      Geolocator.openLocationSettings(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: _onEnterManually,
                child: Text(
                  'Enter manually instead',
                  style: AppTypography.actionSm.copyWith(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.underline,
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

// ─── Location icon badge ──────────────────────────────────────────────────

class _LocationIconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        boxShadow: AppShadows.glow,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.location_on_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}

// ─── Pulse radar + floating chips ─────────────────────────────────────────

class _PulseRadar extends StatelessWidget {
  const _PulseRadar({
    required this.ring1,
    required this.ring2,
    required this.ring3,
    required this.emojiBob,
  });

  final AnimationController ring1;
  final AnimationController ring2;
  final AnimationController ring3;
  final AnimationController emojiBob;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxR = constraints.maxWidth * 0.55;
          return Stack(
            alignment: Alignment.center,
            children: [
              _PulseRing(controller: ring1, maxRadius: maxR),
              _PulseRing(controller: ring2, maxRadius: maxR),
              _PulseRing(controller: ring3, maxRadius: maxR),
              // Center pin.
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.brandGlow,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              // Floating chips — burger top-left, fries top-right.
              Positioned(
                top: maxR * 0.4,
                left: maxR * 0.2,
                child: _FloatingChip(
                  emoji: '🍔',
                  delay: const Duration(milliseconds: 1000),
                  controller: emojiBob,
                  phase: 0,
                ),
              ),
              Positioned(
                top: maxR * 0.5,
                right: maxR * 0.2,
                child: _FloatingChip(
                  emoji: '🍟',
                  delay: const Duration(milliseconds: 1400),
                  controller: emojiBob,
                  phase: 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.controller, required this.maxRadius});
  final AnimationController controller;
  final double maxRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final curve = AppCurves.pulseRing.transform(t);
        final scale = 0.8 + curve * 1.0; // 0.8 → 1.8
        final opacity = (0.5 * (1 - t)).clamp(0.0, 0.5);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: maxRadius * 2,
              height: maxRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingChip extends StatefulWidget {
  const _FloatingChip({
    required this.emoji,
    required this.delay,
    required this.controller,
    required this.phase,
  });
  final String emoji;
  final Duration delay;
  final AnimationController controller;
  final double phase;

  @override
  State<_FloatingChip> createState() => _FloatingChipState();
}

class _FloatingChipState extends State<_FloatingChip> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _shown ? 1 : 0,
      duration: AppDurations.blurFade,
      curve: AppCurves.springOut,
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final raw = (widget.controller.value + widget.phase) % 1.0;
          final dy = -6.0 * (1 - (2 * raw - 1).abs());
          return Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                shape: BoxShape.circle,
                boxShadow: AppShadows.soft,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── CTA ─────────────────────────────────────────────────────────────────

class _ShareLocationCta extends StatelessWidget {
  const _ShareLocationCta({
    required this.status,
    required this.onShare,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  final _LocationStatus status;
  final VoidCallback onShare;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final loading = status == _LocationStatus.requesting;
    final label = switch (status) {
      _LocationStatus.requesting => 'Locating you…',
      _LocationStatus.deniedForever => 'Open Settings',
      _LocationStatus.serviceDisabled => 'Enable Location',
      _LocationStatus.timeout => 'Retry',
      _ => 'Share Location',
    };
    final onTap = switch (status) {
      _LocationStatus.deniedForever => onOpenSettings,
      _LocationStatus.serviceDisabled => onOpenLocationSettings,
      _ => onShare,
    };
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.ctaLg),
          boxShadow: AppShadows.brandGlow,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: AppTypography.buttonLabelLg.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
