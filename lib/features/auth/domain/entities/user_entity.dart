import 'package:flutter/foundation.dart';

/// Represents an authenticated user.
@immutable
class UserEntity {
  final String id;
  final String phone;
  final String? token;

  const UserEntity({
    required this.id,
    required this.phone,
    this.token,
  });
}
