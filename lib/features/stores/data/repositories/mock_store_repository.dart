// ============================================================================
// FILE: lib/features/stores/data/repositories/mock_store_repository.dart
// CHANGES:
//   - Created mock store repository
//   - Returns 1 mock store with a TODO comment for API replacement
// ============================================================================
import 'dart:developer' as developer;
import 'package:burger_farm_app/core/utils/haversine.dart';
import 'package:burger_farm_app/features/stores/domain/entities/store_entity.dart';
import 'package:burger_farm_app/features/stores/domain/repositories/store_repository.dart';

/// Mock implementation of [StoreRepository] with hardcoded data.
///
/// TODO: Replace with real API call — replace with [StoreRepositoryImpl].
class MockStoreRepository implements StoreRepository {
  static const String _tag = 'MOCK_STORE';

  /// Single mock store for navigation testing.
  static final StoreEntity _mockStore = StoreEntity(
    id: 'store-001',
    name: 'Burger Farm - Noida Sector 62',
    address: 'H-block, Sector 62, Noida, Uttar Pradesh 201301',
    latitude: 28.6280,
    longitude: 77.3639,
    isOpen: true,
    imageUrl: 'assets/images/store_front.png',
    phone: '+91-120-1234567',
    openingHours: const ['Mon-Sun: 10:00 AM - 11:00 PM'],
  );

  @override
  Future<List<StoreEntity>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    developer.log(
      'getNearbyStores(lat: $latitude, lng: $longitude, radius: $radiusKm)',
      name: _tag,
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // TODO: Replace with API call to /stores/nearby
    final distance = haversineDistance(
      latitude,
      longitude,
      _mockStore.latitude,
      _mockStore.longitude,
    );

    if (distance <= radiusKm) {
      return [_mockStore.copyWith(distanceKm: distance)];
    }

    return [];
  }

  @override
  Future<StoreEntity?> getStoreById(String id) async {
    developer.log('getStoreById($id)', name: _tag);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (id == _mockStore.id) {
      return _mockStore;
    }
    return null;
  }
}
