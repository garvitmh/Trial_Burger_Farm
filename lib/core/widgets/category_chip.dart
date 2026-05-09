// ============================================================================
// CATEGORY CHIP - Scrollable category item
// ============================================================================
import 'package:flutter/material.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppAnimations.normal,
            width: AppDimensions.categoryIconSize,
            height: AppDimensions.categoryIconSize,
            decoration: BoxDecoration(
              color: isActive ? AppColors.brand : AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: isActive
                  ? null
                  : Border.all(color: AppColors.line.withValues(alpha: 0.6)),
              boxShadow: isActive ? AppShadows.brandGlow : AppShadows.premium,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppColors.brand,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.brown : AppColors.brownMuted,
            ),
          ),
        ],
      ),
    );
  }
}
