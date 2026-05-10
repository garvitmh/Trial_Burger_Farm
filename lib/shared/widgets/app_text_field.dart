import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_durations.dart';

/// AppTextField — Burger Farm Input Field
///
/// Matches CSS .inp spec:
///   - Height: 52px
///   - Border: 1.5px var(--line)
///   - Border radius: 14px
///   - Focus: primary orange border + 3px ring
///   - Font: Recoleta 14px w500
///   - Placeholder: 13px, muted brown
///
/// Strictly design-token driven. No business logic.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.label,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? label;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return AnimatedContainer(
      duration: AppDurations.standard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: _isFocused && !hasError ? AppShadows.inputFocus : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: AppTypography.captionMd.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          SizedBox(
            height: widget.maxLines > 1 ? null : AppSpacing.inputHeight,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              style: AppTypography.inputText.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.inputPlaceholder.copyWith(
                  color: AppColors.textMuted,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: widget.prefixIcon,
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(minWidth: 48),
                suffixIcon: widget.suffixIcon != null
                    ? Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: widget.suffixIcon,
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 48),
                filled: true,
                fillColor: widget.enabled ? Colors.white : AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 1.5),
                ),
                errorText: widget.errorText,
              ),
            ),
          ),
          if (widget.helperText != null && widget.errorText == null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.helperText!,
              style: AppTypography.captionMd.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
