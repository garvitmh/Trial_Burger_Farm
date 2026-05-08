// ============================================================================
// BRAND BUTTON - Primary CTA button with shimmer effect
// ============================================================================
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

class BrandButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final double? height;
  final List<BoxShadow>? shadows;

  const BrandButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.height,
    this.shadows,
  });

  const BrandButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height,
  })  : isSecondary = true,
        shadows = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: isSecondary ? null : (shadows ?? AppShadows.brandGlow),
      ),
      child: Material(
        color: isSecondary ? AppColors.white : AppColors.brand,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          splashColor: isSecondary
              ? AppColors.brand.withOpacity(0.1)
              : AppColors.white.withOpacity(0.2),
          child: Container(
            height: height ?? AppDimensions.buttonHeight,
            alignment: Alignment.center,
            decoration: isSecondary
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    border: Border.all(color: AppColors.line, width: 1.5),
                  )
                : null,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: AppTypography.button.copyWith(
                          color: isSecondary ? AppColors.brand : Colors.white,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          icon,
                          size: 18,
                          color: isSecondary ? AppColors.brand : Colors.white,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
