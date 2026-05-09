import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';
import 'package:burger_farm_app/shared/widgets/premium_button.dart';


/// Menu item detail screen — stub for Phase 2.
class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cream,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.brand),
          ),
        ),
        title: Text('Item Detail', style: AppTypography.display18),
      ),
      body: Center(
        child: Text('🚧 Phase 2 — Coming soon',
            style: AppTypography.body14.copyWith(color: AppColors.brownMuted)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: PremiumButton(text: 'Add to Cart', onPressed: () {}),
      ),
    );
  }
}
