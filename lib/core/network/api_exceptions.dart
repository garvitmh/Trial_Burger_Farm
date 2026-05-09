// ============================================================================
// FILE: lib/core/network/api_exceptions.dart
// CHANGES:
//   - Created domain-specific exception hierarchy
//   - Enables precise error handling in UI layer
// ============================================================================

/// Base exception for all API-related errors.
sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: \$message (status: \$statusCode)';
}

/// Thrown when the device has no internet connection.
class NetworkException extends ApiException {
  const NetworkException() : super('No internet connection. Please check your network.');
}

/// Thrown when the server returns a 5xx error.
class ServerException extends ApiException {
  const ServerException([String message = 'Server error. Please try again later.'])
      : super(message);
}

/// Thrown when the server returns 401 Unauthorized.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Session expired. Please log in again.'])
      : super(message, statusCode: 401);
}

/// Thrown when the server returns 403 Forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException([String message = 'You do not have permission to perform this action.'])
      : super(message, statusCode: 403);
}

/// Thrown when the server returns 422 / validation errors.
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    String message = 'Validation failed. Please check your input.',
    this.errors,
  }) : super(message, statusCode: 422);
}

/// Thrown when the server returns 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException([String message = 'The requested resource was not found.'])
      : super(message, statusCode: 404);
}

/// Thrown when the request times out.
class TimeoutException extends ApiException {
  const TimeoutException() : super('Request timed out. Please try again.');
}

/// Thrown for unknown / unhandled API errors.
class UnknownApiException extends ApiException {
  const UnknownApiException([String message = 'An unexpected error occurred.'])
      : super(message);
}
