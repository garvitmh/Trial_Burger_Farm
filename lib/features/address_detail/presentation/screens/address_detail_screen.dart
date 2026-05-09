// ============================================================================
// ADDRESS DETAIL SCREEN - Flat/House, Building, Landmark + Save As tags
// Matches: detail.html pixel-perfect
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:burger_farm_app/app/router/app_router.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';
import 'package:burger_farm_app/core/widgets/brand_button.dart';
import 'package:burger_farm_app/core/widgets/brand_text_field.dart';
import 'package:burger_farm_app/core/widgets/address_tag.dart';

class AddressDetailScreen extends ConsumerStatefulWidget {
  const AddressDetailScreen({super.key});

  @override
  ConsumerState<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends ConsumerState<AddressDetailScreen> {
  final _flatController = TextEditingController();
  final _buildingController = TextEditingController();
  final _landmarkController = TextEditingController();
  String _saveAs = 'Home';

  final List<Map<String, dynamic>> _tags = [
    {'label': 'Home', 'icon': Icons.home},
    {'label': 'Work', 'icon': Icons.business},
    {'label': 'Other', 'icon': Icons.place},
  ];

  void _saveAddress(BuildContext context) {
    context.go(AppRoute.outlet);
  }

  @override
  void dispose() {
    _flatController.dispose();
    _buildingController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Top Map Area ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFF0F0F0),
                    child: CustomPaint(
                      painter: _DetailMapPainter(),
                    ),
                  ),
                ),
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
                          AppColors.white.withValues(alpha: 0.95),
                          AppColors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
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
                                  color: AppColors.brown.withValues(alpha: 0.05),
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
                          'Add Address Details',
                          style: AppTypography.display18,
                        ),
                      ],
                    ),
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
            top: MediaQuery.of(context).size.height * 0.24,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: AppShadows.float,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ─── Flat/House No ───
                              BrandTextField(
                                controller: _flatController,
                                labelText: 'Flat / House No.',
                                hintText: 'e.g. 42, Tower C',
                                prefixIcon: const Icon(
                                  Icons.apartment,
                                  size: 20,
                                  color: AppColors.brownMuted,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // ─── Building / Society ───
                              BrandTextField(
                                controller: _buildingController,
                                labelText: 'Building / Society',
                                hintText: 'e.g. Sunflower Apartments',
                                prefixIcon: const Icon(
                                  Icons.location_city,
                                  size: 20,
                                  color: AppColors.brownMuted,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // ─── Landmark ───
                              BrandTextField(
                                controller: _landmarkController,
                                labelText: 'Landmark (Optional)',
                                hintText: 'e.g. Near City Mall',
                                prefixIcon: const Icon(
                                  Icons.place,
                                  size: 20,
                                  color: AppColors.brownMuted,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // ─── Save As ───
                              Text(
                                'Save As',
                                style: AppTypography.label,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: _tags.map((tag) {
                                  final label = tag['label'] as String;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: AddressTag(
                                        label: label,
                                        icon: tag['icon'] as IconData,
                                        isSelected: _saveAs == label,
                                        onTap: () => setState(() => _saveAs = label),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                      BrandButton(
                        text: 'Save Address',
                        onPressed: () => _saveAddress(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6;

    for (double y in [size.height * 0.3, size.height * 0.7]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x in [size.width * 0.3, size.width * 0.7]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
