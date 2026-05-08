import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Named shadow presets matching the Tailwind shadow config.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.brown.withOpacity(0.04),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.brown.withOpacity(0.02),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get premium => [
        BoxShadow(
          color: AppColors.brown.withOpacity(0.08),
          blurRadius: 40,
          spreadRadius: -10,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: AppColors.brown.withOpacity(0.05),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get glow => [
        BoxShadow(
          color: AppColors.brand.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get brandGlow => [
        BoxShadow(
          color: AppColors.brand.withOpacity(0.4),
          blurRadius: 30,
          spreadRadius: -10,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.brand.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get float => [
        BoxShadow(
          color: AppColors.brown.withOpacity(0.04),
          blurRadius: 32,
          offset: const Offset(0, -12),
        ),
      ];

  static List<BoxShadow> get insetSoft => [
        BoxShadow(
          color: AppColors.brown.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
