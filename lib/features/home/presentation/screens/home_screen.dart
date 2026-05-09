// ============================================================================
// HOME SCREEN - Main app screen with bottom navigation
// TODO: Replace HomeMockData with real API calls via HomeRepository
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';
import 'package:burger_farm_app/core/widgets/food_card.dart';
import 'package:burger_farm_app/core/widgets/category_chip.dart';
import 'package:burger_farm_app/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:burger_farm_app/features/home/data/home_mock_data.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // TODO: Replace with: final homeData = ref.watch(homeDataProvider);
    final categories = HomeMockData.categories;
    final foodItems = HomeMockData.foodItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ─── Header Section ───
                  const SliverToBoxAdapter(
                    child: _HomeHeader(),
                  ),
                  // ─── Search Bar ───
                  const SliverToBoxAdapter(
                    child: _SearchBar(),
                  ),
                  // ─── Hero Banner ───
                  const SliverToBoxAdapter(
                    child: _HeroBanner(),
                  ),
                  // ─── Categories ───
                  SliverToBoxAdapter(
                    child: _CategoriesSection(categories: categories),
                  ),
                  // ─── Popular Section Title ───
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'Popular Near You',
                      subtitle: '${foodItems.length} Items',
                    ),
                  ),
                  // ─── Food List ───
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = foodItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FoodCard(
                              name: item['name'] as String,
                              description: item['description'] as String,
                              price: '₹${item['price']}',
                              imagePath: item['image'] as String,
                              isVeg: item['isVeg'] as bool,
                              onAddToCart: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item['name']} added to cart!',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: foodItems.length,
                      ),
                    ),
                  ),
                  // Bottom padding for nav bar
                  SliverToBoxAdapter(
                    child: SizedBox(height: bottomPadding + 100),
                  ),
                ],
              ),
              // ─── Floating Bottom Nav ───
              Positioned(
                bottom: bottomPadding + 12,
                left: 16,
                right: 16,
                child: const BottomNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Header ───
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Logo + Address + Profile
          Row(
            children: [
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.brand.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fastfood,
                  size: 20,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(width: 10),
              // Delivery address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Delivering to',
                          style: AppTypography.tag,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sector 62, Noida',
                            style: AppTypography.display16.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.brown,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Profile
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brown.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.transparent,
                  AppColors.line,
                  AppColors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Search Bar ───
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.brown.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                  hintText: 'Search burger, sides, drinks...',
                  hintStyle: AppTypography.inputPlaceholder,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: AppTypography.body13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Banner ───
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.warmBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.line.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.brown.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.brand.withValues(alpha: 0.04),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brand.withValues(alpha: 0.08),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brown.withValues(alpha: 0.05),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Row(
                children: [
                  // Left text
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'The Classic',
                          style: AppTypography.display26.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Farmhouse Stack',
                          style: AppTypography.display26.copyWith(
                            fontSize: 22,
                            color: AppColors.brand,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.brand.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'LIMITED OFFER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brand,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right image area
                  Expanded(
                    flex: 4,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow behind burger
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.brand.withValues(alpha: 0.15),
                                AppColors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Burger image
                        Image.asset(
                          'assets/images/nonveg_burger.png',
                          height: 130,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.fastfood,
                            size: 80,
                            color: AppColors.brand.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
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

// ─── Categories Section ───
class _CategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const _CategoriesSection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: AppTypography.display18.copyWith(fontSize: 16),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See All',
                  style: AppTypography.body13.copyWith(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal scroll
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return CategoryChip(
                  label: cat['label'] as String,
                  icon: cat['icon'] as IconData,
                  isActive: index == 0,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Divider
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.transparent,
                  AppColors.line,
                  AppColors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ───
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.display18.copyWith(fontSize: 16),
          ),
          if (subtitle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
