// ============================================================================
// FILE: lib/features/home/data/home_mock_data.dart
// CHANGES:
//   - Extracted all hardcoded home screen data
//   - Single mock item per list for navigation testing
//   - TODO comments mark where to replace with API calls
// ============================================================================
import 'package:flutter/material.dart';

/// Mock data for the Home screen.
///
/// TODO: Remove mock data — replace with API calls via HomeRepository.
abstract final class HomeMockData {
  HomeMockData._();

  /// Single mock category for navigation testing.
  static const List<Map<String, dynamic>> categories = [
    {'label': 'Burgers', 'icon': Icons.fastfood},
  ];

  /// Single mock food item for navigation testing.
  static const List<Map<String, dynamic>> foodItems = [
    {
      'name': 'Fresh Farmhouse',
      'description': 'Veg Patty, Lettuce, Tomato, Cheese',
      'price': '249',
      'image': 'assets/images/veg_burger.png',
      'isVeg': true,
    },
  ];
}
