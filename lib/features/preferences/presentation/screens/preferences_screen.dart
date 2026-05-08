// ============================================================================
// PREFERENCES SCREEN - Name, Diet toggle, Craving chips
// Matches: preferences.html pixel-perfect
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/brand_button.dart';
import '../../../../core/widgets/preference_toggle.dart';
import '../../../../core/widgets/craving_chip.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final _nameController = TextEditingController();
  bool _isVeg = true;
  final Set<String> _selectedCravings = {'Burgers'};

  final List<Map<String, dynamic>> _cravings = [
    {'label': 'Burgers', 'emoji': '🍔'},
    {'label': 'Sides', 'emoji': '🍟'},
    {'label': 'Drinks', 'emoji': '🥤'},
    {'label': 'Spicy', 'emoji': '🌶️'},
    {'label': 'Light', 'emoji': '🥗'},
  ];

  void _toggleCraving(String label) {
    setState(() {
      if (_selectedCravings.contains(label)) {
        _selectedCravings.remove(label);
      } else {
        _selectedCravings.add(label);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (mounted) {
      context.go(AppRoute.location);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Top Orange Section ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.28,
            child: Container(
              color: AppColors.brand,
              child: Stack(
                children: [
                  // Glow effects
                  Positioned(
                    top: -screenHeight * 0.5,
                    right: -screenHeight * 0.2,
                    child: Container(
                      width: screenHeight * 1.5,
                      height: screenHeight * 1.5,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.white.withOpacity(0.15),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -screenHeight * 0.2,
                    left: -screenHeight * 0.2,
                    child: Container(
                      width: screenHeight * 1.2,
                      height: screenHeight * 1.2,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.brown.withOpacity(0.15),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Center content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.3),
                            ),
                            boxShadow: AppShadows.glow,
                          ),
                          child: const AppLogo(size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Burger Farm',
                          style: AppTypography.display22.copyWith(
                            fontSize: 22,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tell us how you like it',
                          style: AppTypography.body13.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ─── Bottom Sheet ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: screenHeight * 0.26,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: AppShadows.float,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Progress Bar ───
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.brand.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 1.0,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.brand.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 1.0,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.brand,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brand.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Step 3 of 3',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brand,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ─── Form Content ───
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ─── Name Input ───
                              Text(
                                'What do we call you?',
                                style: AppTypography.body16.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.line,
                                    width: 1.5,
                                  ),
                                  boxShadow: AppShadows.insetSoft,
                                ),
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Your first name',
                                    hintStyle: AppTypography.inputPlaceholder,
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(left: 16, right: 8),
                                      child: Icon(
                                        Icons.person,
                                        size: 20,
                                        color: AppColors.brand,
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                  style: AppTypography.input,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // ─── Food Preference ───
                              Text(
                                'Food preference?',
                                style: AppTypography.body16.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: PreferenceToggle(
                                      label: 'Pure Veg',
                                      isVeg: true,
                                      isSelected: _isVeg,
                                      onTap: () => setState(() => _isVeg = true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: PreferenceToggle(
                                      label: 'Non-Veg',
                                      isVeg: false,
                                      isSelected: !_isVeg,
                                      onTap: () => setState(() => _isVeg = false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // ─── Cravings ───
                              Text(
                                'Usually craving?',
                                style: AppTypography.body16.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: _cravings.map((craving) {
                                  final label = craving['label'] as String;
                                  return CravingChip(
                                    label: label,
                                    emoji: craving['emoji'] as String,
                                    isSelected: _selectedCravings.contains(label),
                                    onTap: () => _toggleCraving(label),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                      // ─── CTA ───
                      BrandButton(
                        text: "Let's Eat",
                        icon: Icons.arrow_forward,
                        onPressed: _saveAndContinue,
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
