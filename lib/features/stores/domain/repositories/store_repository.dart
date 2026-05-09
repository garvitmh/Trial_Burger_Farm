// ============================================================================
// FILE: lib/features/stores/domain/repositories/store_repository.dart
// CHANGES:
//   - Created StoreRepository interface
//   - Defines contract for store locator functionality
// ============================================================================
import 'dart:async';
import 'package:burger_farm_app/features/stores/domain/entities/store_entity.dart';

/// Repository contract for store/outlet operations.
abstract class StoreRepository {
  /// Returns nearby stores sorted by distance from the user's location.
  ///
  /// [latitude] and [longitude] are the user's GPS coordinates.
  /// [radiusKm] limits the search radius (default 10km).
  Future<List<StoreEntity>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  });

  /// Returns a specific store by its ID.
  Future<StoreEntity?> getStoreById(String id);
}
