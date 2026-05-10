import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// LocationPermissionStatus — sealed set of all possible location outcomes.
enum _LocationStatus {
  idle,
  requesting,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  unavailable,
}

/// LocationSetupPage — Enterprise location permission rationale screen.
///
/// Handles ALL permission states:
///   - idle         → show rationale + CTA
///   - requesting   → show loading indicator
///   - granted      → proceed to next flow
///   - denied       → show retry path with clear messaging
///   - deniedForever→ show open-settings CTA
///   - serviceDisabled → explain GPS is off, guide to settings
///   - unavailable  → show graceful fallback (enter manually)
///
/// Architecture boundary:
///   - No store data is loaded here.
///   - No map pins or nearby stores are shown (dataset not yet available).
///   - Location visualization and nearest-store logic is deferred.
class LocationSetupPage extends ConsumerStatefulWidget {
  const LocationSetupPage({super.key});

  @override
  ConsumerState<LocationSetupPage> createState() => _LocationSetupPageState();
}

class _LocationSetupPageState extends ConsumerState<LocationSetupPage>
    with TickerProviderStateMixin {
  late AnimationController _ripple1Ctrl;
  late AnimationController _ripple2Ctrl;
  _LocationStatus _status = _LocationStatus.idle;
  String? _errorMessage;

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
    if (_status == _LocationStatus.requesting) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _status = _LocationStatus.requesting;
      _errorMessage = null;
    });

    try {
      // Check if location service is enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _status = _LocationStatus.serviceDisabled;
          _errorMessage =
              'Location services are turned off.\nPlease enable GPS in your device settings.';
        });
        return;
      }

      // Check current permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // First-time request
        permission = await Geolocator.requestPermission();
      }

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          // Granted — proceed
          HapticFeedback.lightImpact();
          setState(() => _status = _LocationStatus.granted);
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) context.go('${RoutePaths.shell}/${RoutePaths.home}');

        case LocationPermission.denied:
          setState(() {
            _status = _LocationStatus.denied;
            _errorMessage =
                'Location access was denied.\nYou can try again or enter your area manually.';
          });

        case LocationPermission.deniedForever:
          setState(() {
            _status = _LocationStatus.deniedForever;
            _errorMessage =
                'Location access was permanently denied.\nPlease enable it in your device Settings.';
          });

        case LocationPermission.unableToDetermine:
          setState(() {
            _status = _LocationStatus.unavailable;
            _errorMessage =
                'Unable to determine location access.\nYou can still enter your area manually.';
          });
      }
    } catch (e) {
      setState(() {
        _status = _LocationStatus.unavailable;
        _errorMessage =
            'Something went wrong while accessing location.\nPlease try again or enter manually.';
      });
    }
  }

  Future<void> _openAppSettings() async {
    HapticFeedback.lightImpact();
    await Geolocator.openAppSettings();
    // After returning from settings, reset to idle for retry
    if (mounted) {
      setState(() {
        _status = _LocationStatus.idle;
        _errorMessage = null;
      });
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
          // Dot-matrix pattern overlay
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _DotMatrixPainter()),
            ),
          ),

          // Top gradient
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

          // Rotating ambient glow
          IgnorePointer(
            child: Center(child: const _RotatingGlow()),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated pin
                  RepaintBoundary(
                    child: _AnimatedLocationPin(
                      ripple1: _ripple1Ctrl,
                      ripple2: _ripple2Ctrl,
                      status: _status,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        duration: 700.ms,
                        curve: const Cubic(0.16, 1, 0.3, 1),
                      )
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Dynamic headline based on status
                  _StatusHeadline(status: _status)
                      .animate(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms)
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Error/info message
                  if (_errorMessage != null)
                    _ErrorBanner(message: _errorMessage!)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.1, end: 0),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),

          // Bottom CTA sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActions(
              status: _status,
              onAllowLocation: _requestLocation,
              onEnterManually: _enterManually,
              onOpenSettings: _openAppSettings,
            )
                .animate(delay: 450.ms)
                .slideY(
                  begin: 0.25,
                  end: 0,
                  duration: 600.ms,
                  curve: const Cubic(0.16, 1, 0.3, 1),
                )
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

// ─── Status-aware headline ─────────────────────────────────────────────────

class _StatusHeadline extends StatelessWidget {
  const _StatusHeadline({required this.status});
  final _LocationStatus status;

  @override
  Widget build(BuildContext context) {
    final (headline, body) = switch (status) {
      _LocationStatus.denied => (
          'Permission Denied',
          'Try allowing access or enter\nyour area manually below.',
        ),
      _LocationStatus.deniedForever => (
          'Access Blocked',
          'Open your device Settings\nand enable location for Burger Farm.',
        ),
      _LocationStatus.serviceDisabled => (
          'GPS is Off',
          'Turn on Location Services in\nyour device settings to continue.',
        ),
      _LocationStatus.unavailable => (
          'Location Unavailable',
          'We couldn\'t access your location.\nYou can enter your area manually.',
        ),
      _LocationStatus.granted => (
          'Location Found!',
          'Great — we\'ll find the closest\nBurger Farm outlet near you.',
        ),
      _ => (
          'Find your nearest\nBurger Farm',
          "We'll show you the closest outlet\nand your estimated delivery time.",
        ),
    };

    return Column(
      children: [
        Text(
          headline,
          textAlign: TextAlign.center,
          style: AppTypography.headlineXL.copyWith(
            color: Colors.white,
            height: 1.15,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: Colors.white.withValues(alpha: 0.80),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.captionMd.copyWith(
          color: Colors.white.withValues(alpha: 0.90),
          height: 1.5,
        ),
      ),
    );
  }
}

// ─── Bottom actions — adapt to permission status ───────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.status,
    required this.onAllowLocation,
    required this.onEnterManually,
    required this.onOpenSettings,
  });
  final _LocationStatus status;
  final Future<void> Function() onAllowLocation;
  final VoidCallback onEnterManually;
  final VoidCallback onOpenSettings;

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
          // Primary CTA — changes based on status
          if (status == _LocationStatus.deniedForever ||
              status == _LocationStatus.serviceDisabled)
            _AllowButton(
              label: 'Open Settings',
              icon: Icons.settings_rounded,
              isLoading: false,
              onTap: () async => onOpenSettings(),
            )
          else
            _AllowButton(
              label: status == _LocationStatus.denied
                  ? 'Try Again'
                  : 'Allow Location',
              icon: status == _LocationStatus.denied
                  ? Icons.refresh_rounded
                  : Icons.location_on_rounded,
              isLoading: status == _LocationStatus.requesting,
              onTap: onAllowLocation,
            ),

          const SizedBox(height: AppSpacing.sm),

          // Ghost: Enter manually (always visible)
          Semantics(
            button: true,
            label: 'Enter location manually',
            child: GestureDetector(
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
          ),
        ],
      ),
    );
  }
}

// ─── Animated location pin ─────────────────────────────────────────────────

class _AnimatedLocationPin extends StatelessWidget {
  const _AnimatedLocationPin({
    required this.ripple1,
    required this.ripple2,
    required this.status,
  });
  final AnimationController ripple1;
  final AnimationController ripple2;
  final _LocationStatus status;

  @override
  Widget build(BuildContext context) {
    final pinColor = switch (status) {
      _LocationStatus.granted => AppColors.success,
      _LocationStatus.denied ||
      _LocationStatus.deniedForever ||
      _LocationStatus.serviceDisabled ||
      _LocationStatus.unavailable =>
        AppColors.error,
      _ => Colors.white,
    };

    final icon = switch (status) {
      _LocationStatus.granted => Icons.check_circle_rounded,
      _LocationStatus.denied ||
      _LocationStatus.deniedForever =>
        Icons.location_off_rounded,
      _LocationStatus.serviceDisabled => Icons.gps_off_rounded,
      _LocationStatus.unavailable => Icons.location_searching_rounded,
      _LocationStatus.requesting => Icons.location_searching_rounded,
      _ => Icons.location_on_rounded,
    };

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
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: const Cubic(0.16, 1, 0.3, 1),
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
            child: status == _LocationStatus.requesting
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Icon(icon, color: pinColor, size: 38),
          ),
        ],
      ),
    );
  }
}

// ─── CTA button ────────────────────────────────────────────────────────────

class _AllowButton extends StatefulWidget {
  const _AllowButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });
  final String label;
  final IconData icon;
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
    _ctrl = AnimationController(vsync: this, duration: 100.ms);
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
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) =>
              Transform.scale(scale: _scale.value, child: child),
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
                      Icon(widget.icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: AppTypography.buttonLabel.copyWith(
                          color: AppColors.primary,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Support painters/widgets ──────────────────────────────────────────────

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
      builder: (context, child) =>
          Transform.rotate(angle: _ctrl.value * 6.28318, child: child),
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
