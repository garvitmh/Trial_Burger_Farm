import 'dart:ui';
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

enum DietPreference { veg, nonVeg, both }

/// PreferencesPage — Burger Farm preferences capture screen, rebuilt to
/// match the Next.js reference (white scaffold + translucent farmer art at
/// the bottom + glass-backed white card with name/dob/phone/diet/terms).
///
/// Architecture note: the form values stay in widget state for now.
/// Firestore persistence is deferred per the briefing's Phase decision.
class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  DietPreference? _diet;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    // Pre-fill phone from any router extra value if available (matches
    // the Next.js reference reading `?phone=` query param).
    final state = GoRouterState.of(context);
    final extra = state.extra;
    if (extra is Map && extra['phone'] is String) {
      _phoneController.text = (extra['phone'] as String)
          .replaceFirst(RegExp(r'^\+91'), '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return _nameController.text.trim().length >= 2 &&
        _dobController.text.isNotEmpty &&
        phoneDigits.length >= 10 &&
        _diet != null &&
        _acceptedTerms;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1925),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceWhite,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _continue() {
    if (!_canContinue) return;
    HapticFeedback.lightImpact();
    context.go(RoutePaths.locationSetup);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ─── Bottom farmer-art illustration + gradient wash ────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.42,
            child: const _FarmerArtBackground(),
          ),
          // ─── Brand-tinted radial wash (corners) ────────────────────────────
          const Positioned.fill(child: _RadialBrandWash()),
          // ─── Foreground content ───────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.xl4),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  BlurFade(
                    delay: const Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/images/brand/logo.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BlurFade(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Personalize your\nBurger Farm feed',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayHeroLg.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BlurFade(
                    delay: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl4,
                      ),
                      child: Text(
                        'Add your preferences to unlock a smoother ordering flow.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: BlurFade(
                      delay: const Duration(milliseconds: 350),
                      child: _PreferencesCard(
                        nameController: _nameController,
                        dobController: _dobController,
                        phoneController: _phoneController,
                        diet: _diet,
                        onDietChanged: (d) {
                          HapticFeedback.selectionClick();
                          setState(() => _diet = d);
                        },
                        acceptedTerms: _acceptedTerms,
                        onTermsChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => _acceptedTerms = v ?? false);
                        },
                        onDobPick: _pickDob,
                        onFieldChanged: () => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: BlurFade(
                      delay: const Duration(milliseconds: 500),
                      child: _ContinueCta(
                        enabled: _canContinue,
                        onTap: _continue,
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

// ─── Background layers ────────────────────────────────────────────────────

class _FarmerArtBackground extends StatelessWidget {
  const _FarmerArtBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.52,
          child: Image.asset(
            'assets/images/preferences/farmer-art.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            errorBuilder: (_, e, s) => const SizedBox.shrink(),
          ),
        ),
        // Warm orange wash bottom → transparent top.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.0, 0.28, 0.55, 0.78, 1.0],
              colors: [
                Color(0x38E8560A), // 22% brand
                Color(0x8CFFE8D2), // 55% peach
                Color(0x60FFF8F2), // 38% near-cream
                Color(0x1FFFFFFF), // 12% white
                Color(0x00FFFFFF),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RadialBrandWash extends StatelessWidget {
  const _RadialBrandWash();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.85, -0.95),
                radius: 0.7,
                colors: [Color(0x14E8560A), Color(0x00E8560A)],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.85, 0.95),
                radius: 0.85,
                colors: [Color(0x1FE8560A), Color(0x00E8560A)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glass card containing the form ───────────────────────────────────────

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.nameController,
    required this.dobController,
    required this.phoneController,
    required this.diet,
    required this.onDietChanged,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.onDobPick,
    required this.onFieldChanged,
  });

  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController phoneController;
  final DietPreference? diet;
  final ValueChanged<DietPreference> onDietChanged;
  final bool acceptedTerms;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onDobPick;
  final VoidCallback onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sheet),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite.withValues(alpha: 0.86),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(AppRadius.sheet),
            boxShadow: AppShadows.premium,
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(text: 'NAME'),
                const SizedBox(height: AppSpacing.sm),
                _StyledInput(
                  controller: nameController,
                  hint: 'Enter your full name',
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.givenName],
                  maxLength: 60,
                  onChanged: (_) => onFieldChanged(),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(text: 'DOB'),
                          const SizedBox(height: AppSpacing.sm),
                          _DateInputButton(
                            controller: dobController,
                            onTap: onDobPick,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(text: 'PHONE'),
                          const SizedBox(height: AppSpacing.sm),
                          _StyledInput(
                            controller: phoneController,
                            hint: '98765 43210',
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumberNational,
                            ],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            maxLength: 10,
                            onChanged: (_) => onFieldChanged(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel(text: 'FOOD PREFERENCE'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _DietToggle(
                        label: 'Veg',
                        active: diet == DietPreference.veg,
                        onTap: () => onDietChanged(DietPreference.veg),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DietToggle(
                        label: 'Non-veg',
                        active: diet == DietPreference.nonVeg,
                        onTap: () => onDietChanged(DietPreference.nonVeg),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DietToggle(
                        label: 'Both',
                        active: diet == DietPreference.both,
                        onTap: () => onDietChanged(DietPreference.both),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _TermsRow(
                  accepted: acceptedTerms,
                  onChanged: onTermsChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.formLabelSm.copyWith(color: AppColors.primary),
    );
  }
}

class _StyledInput extends StatelessWidget {
  const _StyledInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.inputLg),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        onChanged: onChanged,
        style: AppTypography.inputLg.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.inputLg.copyWith(
            color: AppColors.textMuted.withValues(alpha: 0.45),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }
}

class _DateInputButton extends StatelessWidget {
  const _DateInputButton({required this.controller, required this.onTap});
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = controller.text;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppRadius.inputLg),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.centerLeft,
        child: Text(
          value.isEmpty ? 'YYYY-MM-DD' : value,
          style: AppTypography.inputLg.copyWith(
            color: value.isEmpty
                ? AppColors.textMuted.withValues(alpha: 0.45)
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DietToggle extends StatelessWidget {
  const _DietToggle({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.standard,
        curve: AppCurves.material,
        height: 44,
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            width: 2,
            color: active ? AppColors.primary : AppColors.border,
          ),
          boxShadow: active ? AppShadows.glow : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.buttonLabel.copyWith(
            color: active ? AppColors.primary : AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.accepted, required this.onChanged});
  final bool accepted;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: accepted,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: BorderSide(color: AppColors.border, width: 1.5),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTypography.captionMd.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms',
                  style: AppTypography.captionMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTypography.captionMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueCta extends StatefulWidget {
  const _ContinueCta({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_ContinueCta> createState() => _ContinueCtaState();
}

class _ContinueCtaState extends State<_ContinueCta>
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
              'Continue',
              style:
                  AppTypography.buttonLabelLg.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
