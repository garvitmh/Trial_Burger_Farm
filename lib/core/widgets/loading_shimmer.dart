// ============================================================================
// LOADING SHIMMER - Skeleton loader for async states
// ============================================================================
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const LoadingShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
  });

  const LoadingShimmer.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.line.withValues(alpha: 0.5),
      highlightColor: AppColors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius)
              : null,
        ),
      ),
    );
  }
}
