// ============================================================================
// FILE: lib/features/stores/domain/entities/store_entity.dart
// CHANGES:
//   - Created StoreEntity model with id, name, address, coordinates, etc.
// ============================================================================
import 'package:flutter/foundation.dart';

/// Represents a physical Burger Farm store/outlet.
@immutable
class StoreEntity {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final bool isOpen;
  final String? imageUrl;
  final String? phone;
  final List<String> openingHours;

  const StoreEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.isOpen = true,
    this.imageUrl,
    this.phone,
    this.openingHours = const [],
  });

  /// Creates a copy with optionally updated fields.
  StoreEntity copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? distanceKm,
    bool? isOpen,
    String? imageUrl,
    String? phone,
    List<String>? openingHours,
  }) {
    return StoreEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      isOpen: isOpen ?? this.isOpen,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
    );
  }
}
