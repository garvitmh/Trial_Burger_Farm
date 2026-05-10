import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_durations.dart';

/// AppButton — Burger Farm Primary CTA Button
///
/// Matches CSS .btn spec:
///   - Height: 52px
///   - Background: primary orange
///   - Font: Recoleta 15px w700
///   - Border radius: pill (100px)
///   - Shadow: --sh-btn (orange glow)
///   - Active scale: 0.975x
///   - Top gloss overlay (linear-gradient on ::before)
///
/// Strictly design-token driven. No hardcoded values.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width = double.infinity,
    this.height = AppSpacing.buttonHeight,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double width;
  final double height;
  final Widget? icon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
      lowerBound: 0.975,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!_isInteractable) return;
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails _) => _scaleController.forward();
  void _onTapCancel() => _scaleController.forward();

  bool get _isInteractable =>
      !widget.isLoading && !widget.isDisabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = _isInteractable ? 1.0 : 0.5;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _isInteractable ? widget.onPressed : null,
      child: AnimatedOpacity(
        duration: AppDurations.fast,
        opacity: effectiveOpacity,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: _isInteractable ? AppShadows.button : null,
            ),
            child: Stack(
              children: [
                // ── Gloss overlay (matches CSS .btn::before) ──────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: widget.height / 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.button),
                      ),
                      gradient: AppColors.primaryButtonGradient,
                    ),
                  ),
                ),
                // ── Label / Loader ────────────────────────────────────────
                Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              widget.icon!,
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              widget.label,
                              style: AppTypography.buttonLabel.copyWith(
                                color: Colors.white,
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
    );
  }
}

/// AppGhostButton — Ghost button variant (CSS .btn-ghost)
/// Translucent white with border. Used on dark orange backgrounds.
class AppGhostButton extends StatelessWidget {
  const AppGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppSpacing.buttonHeightSm,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.overlayLight,
          foregroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0x2EFFFFFF),
            width: 1.5,
          ),
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabelSm,
        ),
        child: Text(label),
      ),
    );
  }
}

/// AppOutlineButton — Light outline button (CSS .btn-outline)
/// White background with brown text and border. Used on light surfaces.
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppSpacing.buttonHeightSm,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabelSm,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}
