import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';

/// Preference data models — local-only, no backend persistence yet.
enum DietPreference { veg, nonVeg }

class CravingTag {
  const CravingTag({required this.emoji, required this.label});
  final String emoji;
  final String label;
}

const _cravings = [
  CravingTag(emoji: '🍔', label: 'Burgers'),
  CravingTag(emoji: '🍟', label: 'Sides'),
  CravingTag(emoji: '🥤', label: 'Drinks'),
  CravingTag(emoji: '🌶️', label: 'Spicy'),
  CravingTag(emoji: '🥗', label: 'Light'),
  CravingTag(emoji: '🧁', label: 'Desserts'),
];

/// PreferencesPage — User onboarding preferences scaffold.
///
/// Collects: name, diet preference (veg/non-veg), craving tags.
/// No backend persistence yet — architecture boundary is clean for future wiring.
/// Progress: Step 3 of 3 (splash → onboarding → prefs → location).
class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  DietPreference _diet = DietPreference.veg;
  final Set<String> _selectedCravings = {'Burgers'};
  bool _nameFocused = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _nameFocus.addListener(() {
      setState(() => _nameFocused = _nameFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _proceed() {
    HapticFeedback.lightImpact();
    context.go(RoutePaths.locationSetup);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final size = MediaQuery.sizeOf(context);
    final topHeight = size.height * 0.28;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ─── Top Brand Header (orange) ────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topHeight + 32,
            child: _PrefsTopPanel(),
          ),

          // ─── Sheet Content ─────────────────────────────────────────────────
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: topHeight - 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.sheet),
                      ),
                      boxShadow: AppShadows.float,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: AppSpacing.pageH,
                        right: AppSpacing.pageH,
                        top: AppSpacing.lg,
                        bottom: bottomInset + 120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress bar
                          _ProgressBar(step: 3, total: 3)
                              .animate()
                              .fadeIn(duration: 400.ms),

                          const SizedBox(height: AppSpacing.xs),

                          Text(
                            'STEP 3 OF 3',
                            style: AppTypography.labelMicro.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 2.5,
                            ),
                          ).animate(delay: 80.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: AppSpacing.lg),

                          // Name input
                          _SectionLabel(label: 'What do we call you?')
                              .animate(delay: 150.ms)
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: AppSpacing.sm),
                          _NameInputField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hasFocus: _nameFocused,
                          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: AppSpacing.xl),

                          // Diet toggle
                          _SectionLabel(label: 'Food preference?')
                              .animate(delay: 280.ms)
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: AppSpacing.sm),
                          _DietToggle(
                            selected: _diet,
                            onChanged: (d) => setState(() => _diet = d),
                          ).animate(delay: 330.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: AppSpacing.xl),

                          // Cravings
                          _SectionLabel(label: 'Usually craving?')
                              .animate(delay: 410.ms)
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: AppSpacing.sm),
                          _CravingChips(
                            selected: _selectedCravings,
                            onToggle: (tag) {
                              setState(() {
                                if (_selectedCravings.contains(tag)) {
                                  _selectedCravings.remove(tag);
                                } else {
                                  _selectedCravings.add(tag);
                                }
                              });
                              HapticFeedback.selectionClick();
                            },
                          ).animate(delay: 460.ms).fadeIn(duration: 400.ms),
                        ],
                      ),
                    ),
                  ).animate().slideY(
                        begin: 0.08,
                        end: 0,
                        duration: 650.ms,
                        curve: const Cubic(0.16, 1, 0.3, 1),
                      ).fadeIn(duration: 500.ms),
                ),
              ],
            ),
          ),

          // ─── Fixed CTA at bottom ───────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppSpacing.pageH,
                right: AppSpacing.pageH,
                top: AppSpacing.md,
                bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: _ProceedButton(onTap: _proceed)
                  .animate(delay: 600.ms)
                  .slideY(begin: 0.3, end: 0, duration: 500.ms)
                  .fadeIn(duration: 400.ms),
            ),
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

class _PrefsTopPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.primary),
        // Top-right glow
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, -0.8),
                radius: 1.0,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-left glow
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, 0.9),
                radius: 1.0,
                colors: [
                  AppColors.textPrimary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                  ).animate().scale(
                        begin: const Offset(0.7, 0.7),
                        duration: 600.ms,
                        curve: const Cubic(0.16, 1, 0.3, 1),
                      ).fadeIn(duration: 400.ms),
                  const SizedBox(height: 10),
                  Text(
                    'BURGER FARM',
                    style: AppTypography.headlineLg.copyWith(
                      color: Colors.white,
                      letterSpacing: 3.0,
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Tell us how you like it',
                    style: AppTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isComplete = i < step;
        final isCurrent = i == step - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: const Cubic(0.16, 1, 0.3, 1),
              height: 8,
              decoration: BoxDecoration(
                color: isComplete ? AppColors.primary : AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.40),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.bodyMd.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: const Cubic(0.16, 1, 0.3, 1),
      decoration: BoxDecoration(
        color: hasFocus ? AppColors.surfaceWhite : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: hasFocus ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        boxShadow: hasFocus ? AppShadows.inputFocus : null,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Icon(Icons.person_rounded,
                size: 20, color: AppColors.primary),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.words,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Your first name',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DietToggle extends StatelessWidget {
  const _DietToggle({required this.selected, required this.onChanged});
  final DietPreference selected;
  final ValueChanged<DietPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DietOption(
          label: 'Pure Veg',
          icon: '🟢',
          isSelected: selected == DietPreference.veg,
          selectedColor: AppColors.success,
          onTap: () => onChanged(DietPreference.veg),
        ),
        const SizedBox(width: AppSpacing.sm),
        _DietOption(
          label: 'Non-Veg',
          icon: '🔴',
          isSelected: selected == DietPreference.nonVeg,
          selectedColor: AppColors.error,
          onTap: () => onChanged(DietPreference.nonVeg),
        ),
      ],
    );
  }
}

class _DietOption extends StatelessWidget {
  const _DietOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });
  final String label;
  final String icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: const Cubic(0.16, 1, 0.3, 1),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withValues(alpha: 0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isSelected ? selectedColor : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: isSelected ? selectedColor : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CravingChips extends StatelessWidget {
  const _CravingChips({required this.selected, required this.onToggle});
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _cravings
          .map((c) => _CravingChip(
                tag: c,
                isSelected: selected.contains(c.label),
                onTap: () => onToggle(c.label),
              ))
          .toList(),
    );
  }
}

class _CravingChip extends StatelessWidget {
  const _CravingChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });
  final CravingTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: const Cubic(0.16, 1, 0.3, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              tag.label,
              style: AppTypography.bodyMd.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProceedButton extends StatefulWidget {
  const _ProceedButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ProceedButton> createState() => _ProceedButtonState();
}

class _ProceedButtonState extends State<_ProceedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 120.ms);
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
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
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
                "Let's Eat",
                style: AppTypography.buttonLabel.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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
