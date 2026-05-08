// ============================================================================
// ADDRESS SCREEN - Search bar, saved addresses, confirm CTA
// Matches: address.html pixel-perfect
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/brand_button.dart';
import '../../../../core/widgets/address_item.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  void _confirmLocation(BuildContext context) {
    context.go(AppRoute.outlet);
  }

  void _addNewAddress(BuildContext context) {
    context.go(AppRoute.addressDetail);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Top Map Area ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.42,
            child: Stack(
              children: [
                // Map background
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFF0F0F0),
                    child: CustomPaint(
                      painter: _AddressMapPatternPainter(),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 128,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white.withOpacity(0.95),
                          AppColors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Header
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Back button
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.line),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brown.withOpacity(0.05),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: AppColors.brown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Delivery Address',
                          style: AppTypography.display18,
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.line),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brown.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                Icons.search,
                                size: 20,
                                color: AppColors.brownMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search address...',
                                    hintStyle: AppTypography.inputPlaceholder,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  style: AppTypography.input,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Map pin
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _AddressMapPin(),
                  ),
                ),
              ],
            ),
          ),
          // ─── Bottom Sheet ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: AppShadows.float,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Addresses',
                      style: AppTypography.display18,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          AddressItem.home(
                            address: 'Home',
                            subtitle: '123, Green Park, New Delhi',
                            onTap: () => _confirmLocation(context),
                          ),
                          const SizedBox(height: 12),
                          AddressItem.work(
                            address: 'Work',
                            subtitle: 'Tech Park, Sector 62, Noida',
                            onTap: () => _confirmLocation(context),
                          ),
                          const SizedBox(height: 20),
                          // Add new address
                          GestureDetector(
                            onTap: () => _addNewAddress(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.line,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brown.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: AppColors.brand,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add New Address',
                                    style: AppTypography.body14.copyWith(
                                      color: AppColors.brand,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    BrandButton(
                      text: 'Confirm Location',
                      onPressed: () => _confirmLocation(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressMapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6;

    for (double y in [size.height * 0.3, size.height * 0.6]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x in [size.width * 0.25, size.width * 0.5, size.width * 0.75]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AddressMapPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.brand.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.brand,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: AppColors.white,
            size: 20,
          ),
        ),
        Positioned(
          top: 52,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brown.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '18 Min',
                  style: AppTypography.body10.copyWith(
                    color: AppColors.brown,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
