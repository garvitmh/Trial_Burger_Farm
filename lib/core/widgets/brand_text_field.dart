// ============================================================================
// BRAND TEXT FIELD - Premium styled input field
// ============================================================================
import 'package:flutter/material.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';

class BrandTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final TextStyle? textStyle;

  const BrandTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.maxLines = 1,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(labelText!, style: AppTypography.label),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: AppShadows.insetSoft,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            focusNode: focusNode,
            textInputAction: textInputAction,
            maxLines: maxLines,
            style: textStyle ?? AppTypography.input,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.inputPlaceholder,
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                borderSide: const BorderSide(color: AppColors.line, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                borderSide: const BorderSide(color: AppColors.line, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
