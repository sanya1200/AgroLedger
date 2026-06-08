import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._dio, this._storage) {
    _dio
      ..options.baseUrl = 'https://agroledger-zlxo.onrender.com/api/v1/'
          '' // Standard for Android Emulator
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Add JWT token if exists
            final token = await _storage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            // Handle 401 Unauthorized
            if (e.response?.statusCode == 401) {
              await _storage.delete(key: 'access_token');
              // Here we would typically navigate to login screen
              // For now, we just clear the token as requested
            }
            return handler.next(e);
          },
        ),
      );
  }

  Dio get dio => _dio;
}
