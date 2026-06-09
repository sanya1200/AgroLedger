import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    String? phone,
    required String role,
  });
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRemoteDataSourceImpl(this._client, this._storage);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        'auth/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await _storage.write(key: 'access_token', value: token);
        
        return await getMe();
      } else {
        throw Exception('Ошибка входа');
      }
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Ошибка сети';
      throw Exception(message);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    try {
      final response = await _client.dio.post(
        'auth/register',
        data: {
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );

      if (response.statusCode == 201) {
        return await login(email, password);
      } else {
        throw Exception('Ошибка регистрации');
      }
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Ошибка при регистрации';
      throw Exception(message);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _client.dio.get('auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Ошибка авторизации');
    }
  }
}
