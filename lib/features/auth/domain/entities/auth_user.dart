import 'package:flutter/foundation.dart';

/// AuthUser — Core domain entity representing an authenticated user.
///
/// Ensures the presentation and data layers rely on a clean, Firebase-agnostic model.
/// Immutable.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    this.phoneNumber,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
    required this.createdAt,
  });

  /// The unique identifier (UID from Firebase).
  final String id;
  final String? phoneNumber;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  
  /// True if the user hasn't verified a permanent credential.
  final bool isAnonymous;
  
  final DateTime createdAt;

  AuthUser copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
    DateTime? createdAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
