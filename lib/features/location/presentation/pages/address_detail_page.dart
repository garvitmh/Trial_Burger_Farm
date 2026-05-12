import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

enum AddressTag { home, work, other }

/// AddressDetailPage — confirm a selected address with flat/building/landmark
/// details and tag (Home/Work/Other), per the reference `app/address/detail`.
///
/// Receives the selected address via `GoRouterState.extra` as a Map with
/// `title` and `subtitle`. Form values stay in widget state for now;
/// Firestore persistence belongs to the next phase.
class AddressDetailPage extends ConsumerStatefulWidget {
  const AddressDetailPage({super.key});

  @override
  ConsumerState<AddressDetailPage> createState() => _AddressDetailPageState();
}

class _AddressDetailPageState extends ConsumerState<AddressDetailPage> {
  final _flat = TextEditingController();
  final _building = TextEditingController();
  final _landmark = TextEditingController();
  AddressTag _tag = AddressTag.home;
  String _title = 'Delivery Location';
  String _subtitle = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map) {
        setState(() {
          if (extra['title'] is String) _title = extra['title'] as String;
          if (extra['subtitle'] is String) _subtitle = extra['subtitle'] as String;
        });
      }
    });
  }

  @override
  void dispose() {
    _flat.dispose();
    _building.dispose();
    _landmark.dispose();
    super.dispose();
  }

  bool get _canSave => _flat.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;
    HapticFeedback.lightImpact();
    // TODO(phase-store): persist to users/{uid}/addresses/ in Firestore via
    // a dedicated repository. For now, navigate to home.
    context.go('${RoutePaths.shell}/${RoutePaths.home}');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mapHeight = size.height * 0.22;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Map snapshot ────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            child: _MapSnapshot(onBack: () => context.pop()),
          ),
          // ── Form card overlay ──────────────────────────────────────────
          Positioned(
            top: mapHeight - 24,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Column(
                children: [
                  _LocationSummary(title: _title, subtitle: _subtitle),
                  Container(height: 1, color: AppColors.border),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        bottomInset + AppSpacing.xl,
                      ),
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlurFade(
                              delay: const Duration(milliseconds: 200),
                              child: _AddressField(
                                label: 'FLAT / HOUSE NO.',
                                required: true,
                                controller: _flat,
                                hint: 'e.g., 12A, Floor 2',
                                icon: Icons.home_outlined,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            BlurFade(
                              delay: const Duration(milliseconds: 300),
                              child: _AddressField(
                                label: 'BUILDING / SOCIETY',
                                controller: _building,
                                hint: 'e.g., Green Valley Apartments',
                                icon: Icons.apartment_rounded,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            BlurFade(
                              delay: const Duration(milliseconds: 400),
                              child: _AddressField(
                                label: 'LANDMARK',
                                optional: true,
                                controller: _landmark,
                                hint: 'e.g., Near the park',
                                icon: Icons.info_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            BlurFade(
                              delay: const Duration(milliseconds: 500),
                              child: Text(
                                'SAVE AS',
                                style: AppTypography.formLabel.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            BlurFade(
                              delay: const Duration(milliseconds: 540),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _TagTile(
                                      label: 'Home',
                                      icon: Icons.home_rounded,
                                      active: _tag == AddressTag.home,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _tag = AddressTag.home);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _TagTile(
                                      label: 'Work',
                                      icon: Icons.work_outline_rounded,
                                      active: _tag == AddressTag.work,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _tag = AddressTag.work);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _TagTile(
                                      label: 'Other',
                                      icon: Icons.location_on_outlined,
                                      active: _tag == AddressTag.other,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _tag = AddressTag.other);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Footer CTA — anchored above keyboard.
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.4),
                        ),
                      ),
                      boxShadow: AppShadows.float,
                    ),
                    child: SafeArea(
                      top: false,
                      child: BlurFade(
                        delay: const Duration(milliseconds: 700),
                        child: Column(
                          children: [
                            _SaveCta(enabled: _canSave, onTap: _save),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Your address will be saved for future orders.',
                              style: AppTypography.captionMd.copyWith(
                                color: AppColors.textMuted.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Map snapshot ─────────────────────────────────────────────────────────

class _MapSnapshot extends StatelessWidget {
  const _MapSnapshot({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: CustomPaint(painter: _PolkaDotPainter()),
          ),
          // Subtle top→bottom darkening gradient.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x10000000), Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          // Back button.
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onBack();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      boxShadow: AppShadows.soft,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Brand pin in the center.
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceWhite, width: 2),
                boxShadow: AppShadows.glow,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolkaDotPainter extends CustomPainter {
  const _PolkaDotPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border;
    const step = 24.0;
    for (double y = step / 2; y < size.height; y += step) {
      for (double x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PolkaDotPainter old) => false;
}

// ─── Location summary ─────────────────────────────────────────────────────

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brandLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.sectionLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.captionMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form field ───────────────────────────────────────────────────────────

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.required = false,
    this.optional = false,
    this.onChanged,
  });
  final String label;
  final bool required;
  final bool optional;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.formLabel.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppTypography.formLabel.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
            if (optional) ...[
              const SizedBox(width: 6),
              Text(
                '(Optional)',
                style: AppTypography.captionMd.copyWith(
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.cellLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: required
                    ? AppColors.primary
                    : AppColors.textMuted.withValues(alpha: 0.6),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: AppTypography.inputLg.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTypography.inputLg.copyWith(
                      color: AppColors.textMuted.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tag tile ─────────────────────────────────────────────────────────────

class _TagTile extends StatelessWidget {
  const _TagTile({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: AppCurves.material,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surfaceWhite,
          border: Border.all(
            width: 1.5,
            color: active ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadius.cellLg),
          boxShadow: active ? AppShadows.soft : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active
                  ? AppColors.primary
                  : AppColors.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.formLabel.copyWith(
                color: active
                    ? AppColors.primary
                    : AppColors.textMuted.withValues(alpha: 0.6),
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Save CTA ─────────────────────────────────────────────────────────────

class _SaveCta extends StatefulWidget {
  const _SaveCta({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_SaveCta> createState() => _SaveCtaState();
}

class _SaveCtaState extends State<_SaveCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press =
      AnimationController(vsync: this, duration: AppDurations.fast);

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppDurations.standard,
      opacity: widget.enabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => _press.forward() : null,
        onTapUp: widget.enabled
            ? (_) {
                _press.reverse();
                widget.onTap();
              }
            : null,
        onTapCancel: () => _press.reverse(),
        child: AnimatedBuilder(
          animation: _press,
          builder: (context, child) => Transform.scale(
            scale: 1 - _press.value * 0.03,
            child: child,
          ),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.ctaLg),
              boxShadow: widget.enabled ? AppShadows.brandGlow : null,
            ),
            alignment: Alignment.center,
            child: Text(
              'Save & Continue',
              style:
                  AppTypography.buttonLabelLg.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
