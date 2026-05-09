// ============================================================================
// FILE: lib/core/network/api_client.dart
// CHANGES:
//   - Created Dio wrapper with interceptors
//   - Added RequestLoggerInterceptor and AuthInterceptor
// ============================================================================
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:burger_farm_app/core/config/app_config.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';
import 'package:burger_farm_app/core/services/secure_storage_service.dart';

/// Centralized HTTP client with interceptors for auth, logging, and error handling.
///
/// Use this instead of raw [Dio] instances to ensure consistent behavior.
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseApiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      if (AppConfig.enableNetworkLogging) RequestLoggerInterceptor(),
      AuthInterceptor(),
      ErrorMappingInterceptor(),
    ]);
  }

  Dio get client => _dio;

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PUT request.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}

/// Attaches the Bearer token to every outgoing request.
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Logs request/response details in debug builds.
class RequestLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('➡️  ${options.method} ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) debugPrint('Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ ${err.response?.statusCode} ${err.requestOptions.uri}');
    debugPrint('Error: ${err.message}');
    handler.next(err);
  }
}

/// Maps Dio errors to domain-specific [ApiException] subclasses.
class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          return const NetworkException();
        }
        return const UnknownApiException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.data?['message'] as String? ?? 'Server error';
        switch (statusCode) {
          case 401:
            return UnauthorizedException(message);
          case 403:
            return ForbiddenException(message);
          case 404:
            return NotFoundException(message);
          case 422:
            final errors = error.response?.data?['errors'] as Map<String, dynamic>?;
            return ValidationException(
              message: message,
              errors: errors?.map(
                (key, value) => MapEntry(key, List<String>.from(value as List)),
              ),
            );
          default:
            if (statusCode >= 500) return ServerException(message);
            return UnknownApiException(message);
        }
      case DioExceptionType.badCertificate:
        return const UnknownApiException('SSL certificate error');
      case DioExceptionType.cancel:
        return const UnknownApiException('Request was cancelled');
    }
  }
}
