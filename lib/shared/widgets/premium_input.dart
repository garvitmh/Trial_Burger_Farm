import 'package:flutter/material.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';

/// Styled input field with animated focus state and brand border glow.
class PremiumInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool required;
  final int? maxLength;

  const PremiumInput({
    super.key,
    this.label,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.controller,
    this.required = false,
    this.maxLength,
  });

  @override
  State<PremiumInput> createState() => _PremiumInputState();
}

class _PremiumInputState extends State<PremiumInput> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: AppColors.brownMuted,
                ),
              ),
              if (widget.required)
                Text(
                  ' *',
                  style: AppTypography.body(size: 12, color: AppColors.brand),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: AppAnimations.spring,
            decoration: BoxDecoration(
              color: _focused ? Colors.white : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focused
                    ? AppColors.brand.withValues(alpha: 0.4)
                    : AppColors.line,
                width: 1.5,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      ...AppShadows.insetSoft,
                    ]
                  : AppShadows.insetSoft,
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  const SizedBox(width: 16),
                  widget.prefixIcon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    onChanged: widget.onChanged,
                    maxLength: widget.maxLength,
                    style: AppTypography.body(
                      size: 16,
                      weight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: AppTypography.body(
                        size: 16,
                        color: AppColors.brownMuted.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 4,
                      ),
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  const SizedBox(width: 12),
                  widget.suffixIcon!,
                  const SizedBox(width: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
