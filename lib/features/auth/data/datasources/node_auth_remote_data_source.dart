import 'package:dio/dio.dart';

class NodeAuthRemoteDataSource {
  final Dio _dio = Dio(BaseOptions(
    // 10.0.2.2 is the special IP for Android Emulator to access localhost
    baseUrl: 'http://10.0.2.2:5000',
    connectTimeout: const Duration(seconds: 5),
  ));

  Future<Map<String, dynamic>> verifyIdToken(String idToken) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {'idToken': idToken},
    );
    return response.data;
  }
}
