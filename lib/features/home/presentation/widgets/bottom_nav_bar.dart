// ============================================================================
// BOTTOM NAV BAR - Floating glassmorphic navigation
// 4 tabs: Home, Offers, Orders, Profile
// ============================================================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.line.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.local_offer_rounded,
                label: 'Offers',
                isActive: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.receipt_rounded,
                label: 'Orders',
                isActive: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.brand : AppColors.brownMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: isActive
                  ? AppTypography.bottomNavLabel.copyWith(color: AppColors.brand)
                  : AppTypography.bottomNavLabelInactive,
            ),
          ],
        ),
      ),
    );
  }
}
