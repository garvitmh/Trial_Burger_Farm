// ============================================================================
// FILE: lib/core/network/base_response.dart
// CHANGES:
//   - Created standardized API response wrapper
//   - All API calls return BaseResponse<T> for consistency
// ============================================================================
import 'package:flutter/foundation.dart';

/// Standardized API response wrapper.
///
/// Every backend endpoint returns this envelope structure:
/// ```json
/// {
///   "success": true,
///   "data": { ... },
///   "message": "Optional message"
/// }
/// ```
@immutable
class BaseResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? meta;

  const BaseResponse({
    required this.success,
    this.data,
    this.message,
    this.meta,
  });

  /// Creates a [BaseResponse] from JSON with a typed data parser.
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] as bool? ?? false,
      data: json.containsKey('data') && json['data'] != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  /// Converts to JSON with a typed data serializer.
  Map<String, dynamic> toJson(Object? Function(T data) toJsonT) {
    return {
      'success': success,
      if (data != null) 'data': toJsonT(data),
      if (message != null) 'message': message,
      if (meta != null) 'meta': meta,
    };
  }

  /// Whether the response indicates a successful operation.
  bool get isSuccess => success;

  /// Whether the response has a non-null data payload.
  bool get hasData => data != null;
}
