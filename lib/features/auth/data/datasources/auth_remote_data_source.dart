import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String identity, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    required String phone,
    required String role,
    String? fullName,
  });
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRemoteDataSourceImpl(this._client, this._storage);

  // Helper to get device meta (for a real app, use device_info_plus)
  Map<String, String> _getDeviceHeaders() {
    return {
      'X-Device-Fingerprint': 'emulator_fingerprint_v2', // Change for production
      'X-Device-Name': 'Android Emulator',
    };
  }

  @override
  Future<UserModel> login(String identity, String password) async {
    try {
      final response = await _client.dio.post(
        'auth/signin',
        data: {
          'email_or_phone': identity,
          'password': password,
        },
        options: Options(headers: _getDeviceHeaders()),
      );

      final bool success = (response.data is Map) ? (response.data['success'] ?? false) : false;
      if (success) {
        final tokenData = response.data['data'];
        await _storage.write(key: 'access_token', value: tokenData['access_token']);
        await _storage.write(key: 'refresh_token', value: tokenData['refresh_token']);
        
        return await getMe();
      } else {
        final error = (response.data is Map) ? (response.data['error'] ?? 'Ошибка входа') : 'Ошибка входа';
        throw Exception(error);
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final statusCode = e.response?.statusCode;
      String message = 'Ошибка сети ($statusCode)';
      if (responseData is Map) {
        message = responseData['error'] ?? responseData['detail']?.toString() ?? 'Ошибка входа ($statusCode)';
      } else if (responseData is String && responseData.isNotEmpty) {
        message = responseData;
      }
      print('Login Error: $message');
      throw Exception(message);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String phone,
    required String role,
    String? fullName,
  }) async {
    try {
      final response = await _client.dio.post(
        'auth/signup',
        data: {
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
          'full_name': fullName ?? '',
        },
      );

      final bool success = (response.data is Map) ? (response.data['success'] ?? false) : false;
      if (success) {
        // Automatically login after signup
        return await login(email, password);
      } else {
        final error = (response.data is Map) ? (response.data['error'] ?? 'Ошибка регистрации') : 'Ошибка регистрации';
        throw Exception(error);
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final statusCode = e.response?.statusCode;
      String message = 'Ошибка сети ($statusCode)';
      if (responseData is Map) {
        message = responseData['error'] ?? responseData['detail']?.toString() ?? 'Ошибка сервера ($statusCode)';
      } else if (responseData is String && responseData.isNotEmpty) {
        message = responseData;
      }
      print('Signup Error: $message');
      throw Exception(message);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _client.dio.get('auth/me');
      final bool success = (response.data is Map) ? (response.data['success'] ?? false) : false;
      if (success) {
        return UserModel.fromJson(response.data);
      } else {
        final error = (response.data is Map) ? (response.data['error'] ?? 'Ошибка получения данных') : 'Ошибка получения данных';
        throw Exception(error);
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final statusCode = e.response?.statusCode;
      String message = 'Ошибка авторизации ($statusCode)';
      if (responseData is Map) {
        message = responseData['error'] ?? responseData['detail']?.toString() ?? 'Ошибка сессии ($statusCode)';
      } else if (responseData is String && responseData.isNotEmpty) {
        message = responseData;
      }
      print('GetMe Error: $message');
      throw Exception(message);
    }
  }
}
