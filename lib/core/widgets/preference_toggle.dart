// ============================================================================
// PREFERENCE TOGGLE - Veg / Non-Veg selection toggle
// ============================================================================
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class PreferenceToggle extends StatelessWidget {
  final String label;
  final bool isVeg;
  final bool isSelected;
  final VoidCallback? onTap;

  const PreferenceToggle({
    super.key,
    required this.label,
    required this.isVeg,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isVeg ? AppColors.success : AppColors.danger;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.spring,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.line,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppShadows.soft : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DietIcon(isVeg: isVeg, isSelected: isSelected),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? activeColor : AppColors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietIcon extends StatelessWidget {
  final bool isVeg;
  final bool isSelected;

  const _DietIcon({required this.isVeg, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? (isVeg ? AppColors.success : AppColors.danger)
        : AppColors.brownMuted;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: isVeg
            ? Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            : Icon(Icons.close, size: 10, color: color),
      ),
    );
  }
}
