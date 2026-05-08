// ============================================================================
// ADDRESS ITEM - Saved address list item
// ============================================================================
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

class AddressItem extends StatelessWidget {
  final String label;
  final String address;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const AddressItem({
    super.key,
    required this.label,
    required this.address,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    this.onTap,
  });

  const AddressItem.home({
    super.key,
    required this.address,
    required this.subtitle,
    this.onTap,
  })  : label = 'Home',
        icon = Icons.home,
        iconBgColor = AppColors.brand;

  const AddressItem.work({
    super.key,
    required this.address,
    required this.subtitle,
    this.onTap,
  })  : label = 'Work',
        icon = Icons.business,
        iconBgColor = const Color(0xFF5B6CF6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius2xl - 4),
          border: Border.all(color: AppColors.line.withOpacity(0.4)),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line.withOpacity(0.5)),
              ),
              child: Icon(icon, size: 20, color: AppColors.brown),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTypography.body14.copyWith(fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(text: label),
                        TextSpan(
                          text: ' — \$address',
                          style: AppTypography.body14.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.brownMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body11.copyWith(
                      color: AppColors.brownMuted.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.warmBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right, size: 16, color: AppColors.brown),
            ),
          ],
        ),
      ),
    );
  }
}
