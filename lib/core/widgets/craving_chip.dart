// ============================================================================
// CRAVING CHIP - Toggleable preference chip
// ============================================================================
import 'package:flutter/material.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';

class CravingChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback? onTap;

  const CravingChip({
    super.key,
    required this.label,
    required this.emoji,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.spring,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandLight.withValues(alpha: 0.8) : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.brand : AppColors.line,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppShadows.soft : [AppShadows.soft.first],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.brand : AppColors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
