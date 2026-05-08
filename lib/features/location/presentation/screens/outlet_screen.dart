// ============================================================================
// OUTLET SELECTOR SCREEN - Map area + outlet list sheet
// Matches: outlet.html pixel-perfect
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/outlet_card.dart';

class OutletScreen extends ConsumerStatefulWidget {
  const OutletScreen({super.key});

  @override
  ConsumerState<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends ConsumerState<OutletScreen> {
  bool _isDelivery = true;

  final List<Map<String, dynamic>> _outlets = [
    {
      'name': 'Burger Farm — CP',
      'address': 'Shop 12, Block B, Connaught Place, New Delhi',
      'status': OutletStatus.open,
      'distance': '1.2 km',
      'time': '18–22 min',
      'isSelected': true,
    },
    {
      'name': 'Burger Farm — Rajouri',
      'address': 'J-14, Main Market Road, New Delhi',
      'status': OutletStatus.closingSoon,
      'distance': '2.8 km',
      'time': '28–32 min',
      'isSelected': false,
    },
    {
      'name': 'Burger Farm — Saket',
      'address': 'Select Citywalk, Ground Floor, New Delhi',
      'status': OutletStatus.closed,
      'distance': '4.5 km',
      'time': 'Opens 11 AM',
      'isSelected': false,
    },
  ];

  void _selectOutlet(BuildContext context) {
    context.go(AppRoute.home);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Top Map Area ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.40,
            child: Stack(
              children: [
                // Map pattern background
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFF0F0F0),
                    child: CustomPaint(
                      painter: _MapRoadsPainter(),
                    ),
                  ),
                ),
                // Gradient overlay for header
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
                          AppColors.white.withOpacity(0.9),
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
                          'Select Outlet',
                          style: AppTypography.display18,
                        ),
                        const SizedBox(height: 12),
                        // ─── Segmented Control ───
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.line),
                            boxShadow: AppShadows.insetSoft,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SegmentedButton(
                                  label: 'Delivery',
                                  icon: Icons.delivery_dining,
                                  isActive: _isDelivery,
                                  onTap: () => setState(() => _isDelivery = true),
                                ),
                              ),
                              Expanded(
                                child: _SegmentedButton(
                                  label: 'Pickup',
                                  icon: Icons.shopping_bag,
                                  isActive: !_isDelivery,
                                  onTap: () => setState(() => _isDelivery = false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Map pin center
                Positioned(
                  top: screenHeight * 0.15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _BouncingMapPin(),
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
            top: screenHeight * 0.36,
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearest Outlets',
                      style: AppTypography.display18,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _outlets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final outlet = _outlets[index];
                          return OutletCard(
                            name: outlet['name'] as String,
                            address: outlet['address'] as String,
                            status: outlet['status'] as OutletStatus,
                            distance: outlet['distance'] as String?,
                            timeEstimate: outlet['time'] as String?,
                            isSelected: outlet['isSelected'] as bool,
                            onTap: () => _selectOutlet(context),
                          );
                        },
                      ),
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

// ─── Segmented Button ───
class _SegmentedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _SegmentedButton({
    required this.label,
    required this.icon,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brand : AppColors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isActive ? AppShadows.brandGlow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.white : AppColors.brownMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.white : AppColors.brownMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map Roads Painter ───
class _MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Horizontal roads
    for (double y in [size.height * 0.25, size.height * 0.5, size.height * 0.75]) {
      final path = Path();
      path.moveTo(0, y);
      path.quadraticBezierTo(
        size.width * 0.25, y - 25,
        size.width * 0.5, y + 25,
      );
      path.quadraticBezierTo(
        size.width * 0.75, y + 50,
        size.width, y - 10,
      );
      canvas.drawPath(path, paint);
    }

    // Vertical roads
    for (double x in [size.width * 0.25, size.width * 0.5, size.width * 0.75]) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Bouncing Map Pin ───
class _BouncingMapPin extends StatefulWidget {
  @override
  State<_BouncingMapPin> createState() => _BouncingMapPinState();
}

class _BouncingMapPinState extends State<_BouncingMapPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * _controller.value),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Ripple
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brand.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          // Pin
          Container(
            width: 48,
            height: 48,
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
          // Info bubble
          Positioned(
            top: 56,
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
      ),
    );
  }
}
