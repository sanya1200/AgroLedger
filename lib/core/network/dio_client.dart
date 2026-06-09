import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._dio, this._storage) {
    _dio
      ..options.baseUrl = 'https://agroledger-zlxo.onrender.com/api/v1/'
      ..options.connectTimeout = const Duration(seconds: 15)
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
              final refreshToken = await _storage.read(key: 'refresh_token');
              if (refreshToken != null) {
                try {
                  // Attempt to refresh token
                  final response = await Dio().post(
                    '${_dio.options.baseUrl}auth/refresh',
                    queryParameters: {'refresh_token': refreshToken},
                    headers: {
                      'X-Device-Fingerprint': 'agro_device_id_default',
                      'X-Device-Name': 'Mobile App',
                    },
                  );
                  
                  if (response.data['success'] == true) {
                    final newData = response.data['data'];
                    await _storage.write(key: 'access_token', value: newData['access_token']);
                    await _storage.write(key: 'refresh_token', value: newData['refresh_token']);
                    
                    // Retry original request
                    final options = e.requestOptions;
                    options.headers['Authorization'] = 'Bearer ${newData['access_token']}';
                    final retryResponse = await _dio.fetch(options);
                    return handler.resolve(retryResponse);
                  }
                } catch (refreshError) {
                  // Refresh failed, clear everything
                  await _storage.delete(key: 'access_token');
                  await _storage.delete(key: 'refresh_token');
                }
              } else {
                await _storage.delete(key: 'access_token');
              }
            }
            return handler.next(e);
          },
        ),
      );
  }

  Dio get dio => _dio;
}
