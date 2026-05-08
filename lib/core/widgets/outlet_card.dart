// ============================================================================
// OUTLET CARD - Restaurant location card
// ============================================================================
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum OutletStatus { open, closingSoon, closed }

class OutletCard extends StatelessWidget {
  final String name;
  final String address;
  final OutletStatus status;
  final String? distance;
  final String? timeEstimate;
  final bool isSelected;
  final VoidCallback? onTap;

  const OutletCard({
    super.key,
    required this.name,
    required this.address,
    required this.status,
    this.distance,
    this.timeEstimate,
    this.isSelected = false,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case OutletStatus.open:
        return AppColors.success;
      case OutletStatus.closingSoon:
        return AppColors.warning;
      case OutletStatus.closed:
        return AppColors.danger;
    }
  }

  Color get _statusBgColor {
    switch (status) {
      case OutletStatus.open:
        return AppColors.successLight;
      case OutletStatus.closingSoon:
        return AppColors.warningLight;
      case OutletStatus.closed:
        return AppColors.dangerLight;
    }
  }

  String get _statusLabel {
    switch (status) {
      case OutletStatus.open:
        return 'Open';
      case OutletStatus.closingSoon:
        return 'Closing Soon';
      case OutletStatus.closed:
        return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: status == OutletStatus.closed ? null : onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
          border: Border.all(
            color: isSelected ? AppColors.brand : AppColors.line,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brand.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.body16.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address,
                        style: AppTypography.body12,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: _statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (distance != null || timeEstimate != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.line),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (distance != null) ...[
                    _InfoRow(icon: Icons.location_on, text: distance!),
                    const SizedBox(width: 16),
                  ],
                  if (timeEstimate != null)
                    _InfoRow(icon: Icons.access_time, text: timeEstimate!),
                  if (isSelected) ...[
                    const Spacer(),
                    Text(
                      'Select',
                      style: AppTypography.body13.copyWith(color: AppColors.brand),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 14, color: AppColors.brand),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.brand),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.body13.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
