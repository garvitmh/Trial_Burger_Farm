// ============================================================================
// FOOD CARD - Popular item card matching HTML design
// ============================================================================
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

class FoodCard extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final String imagePath;
  final bool isVeg;
  final bool isInCart;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const FoodCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.isVeg = true,
    this.isInCart = false,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
          border: Border.all(color: AppColors.line, width: 1.5),
          boxShadow: AppShadows.premium,
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: AppDimensions.foodCardImageSize,
              height: AppDimensions.foodCardImageSize,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Veg/Non-Veg indicator
                  Row(
                    children: [
                      _DietIndicator(isVeg: isVeg),
                      const SizedBox(width: 6),
                      Text(
                        isVeg ? 'Veg' : 'Non-Veg',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isVeg ? AppColors.success : AppColors.danger,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Name
                  Text(
                    name,
                    style: AppTypography.body16.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    description,
                    style: AppTypography.body12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Price + Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: AppTypography.price,
                      ),
                      _AddButton(
                        isInCart: isInCart,
                        onTap: onAddToCart,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietIndicator extends StatelessWidget {
  final bool isVeg;

  const _DietIndicator({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppColors.success : AppColors.danger;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: isVeg ? BoxShape.circle : BoxShape.rectangle,
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool isInCart;
  final VoidCallback? onTap;

  const _AddButton({this.isInCart = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isInCart ? AppColors.white : AppColors.brand,
          shape: BoxShape.circle,
          border: isInCart
              ? Border.all(color: AppColors.brand, width: 1.5)
              : null,
          boxShadow: isInCart ? null : AppShadows.glow,
        ),
        child: Icon(
          Icons.add,
          size: 14,
          color: isInCart ? AppColors.brand : Colors.white,
        ),
      ),
    );
  }
}
