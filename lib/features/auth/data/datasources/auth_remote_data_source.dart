import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';
import 'dart:developer' as dev;

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

  Map<String, String> _getDeviceHeaders() {
    return {
      'X-Device-Fingerprint': 'agro_device_id_default',
      'X-Device-Name': 'Mobile App',
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

      final data = response.data;
      if (data != null && data['success'] == true) {
        final tokenData = data['data'];
        await _storage.write(key: 'access_token', value: tokenData['access_token']);
        await _storage.write(key: 'refresh_token', value: tokenData['refresh_token']);
        
        return await getMe();
      } else {
        throw data?['error'] ?? 'Ошибка входа';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
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

      final data = response.data;
      if (data != null && data['success'] == true) {
        // After successful signup, we log in to get tokens
        return await login(email, password);
      } else {
        throw data?['error'] ?? 'Ошибка регистрации';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _client.dio.get('auth/me');
      final data = response.data;
      if (data != null && data['success'] == true) {
        return UserModel.fromJson(Map<String, dynamic>.from(data['data']));
      } else {
        throw data?['error'] ?? 'Ошибка получения профиля';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  String _handleDioError(DioException e) {
    dev.log('DioError: ${e.type}', error: e, name: 'AuthRemoteDataSource');
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map) {
        if (data['error'] != null) return data['error'].toString();
        
        final detail = data['detail'];
        if (detail is List) {
          // FastAPI validation error format
          try {
            final firstError = detail.first;
            final msg = firstError['msg'];
            final loc = firstError['loc']?.last;
            return 'Ошибка в поле $loc: $msg';
          } catch (_) {
            return 'Ошибка валидации данных';
          }
        }
        if (detail is String) return detail;
        
        return 'Ошибка сервера';
      }
      return 'Ошибка сервера (${e.response?.statusCode})';
    }
    if (e.type == DioExceptionType.connectionTimeout) return 'Превышено время ожидания';
    if (e.type == DioExceptionType.receiveTimeout) return 'Сервер отвечает слишком долго';
    return 'Проблемы с интернет-соединением';
  }
}
