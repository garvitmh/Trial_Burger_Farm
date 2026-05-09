// ============================================================================
// FILE: lib/features/location/data/store_mock_data.dart
// CHANGES:
//   - Extracted all hardcoded location/outlet data
//   - Single mock store for navigation testing
// ============================================================================

/// Mock data for the Location / Outlet screens.
///
/// TODO: Replace with API — use StoreRepository.getNearbyStores().
abstract final class StoreMockData {
  StoreMockData._();

  /// Single mock store for navigation testing.
  static const List<Map<String, dynamic>> stores = [
    {
      'name': 'Burger Farm - Noida Sector 62',
      'address': 'H-block, Sector 62, Noida, Uttar Pradesh 201301',
      'distance': '2.4 km',
      'time': '18 min',
      'isOpen': true,
    },
  ];
}
