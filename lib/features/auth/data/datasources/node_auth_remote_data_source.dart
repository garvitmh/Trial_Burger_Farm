import 'package:dio/dio.dart';
import 'package:burger_farm_app/core/config/app_config.dart';

/// Remote data source for Node.js backend authentication.
class NodeAuthRemoteDataSource {
  final Dio _dio;

  NodeAuthRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.baseApiUrl,
                connectTimeout: const Duration(seconds: 5),
              ),
            );

  Future<Map<String, dynamic>> verifyIdToken(String idToken) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {'idToken': idToken},
    );
    return response.data as Map<String, dynamic>;
  }
}
