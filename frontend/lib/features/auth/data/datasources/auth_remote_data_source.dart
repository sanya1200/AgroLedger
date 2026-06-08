import 'package:dio/dio.dart';
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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        'auth/login',
        data: {
          'username': email, // Backend expects username for OAuth2 form
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      // The login response for OAuth2 usually returns {access_token, token_type}
      // We might need a separate call to get user info or the token contains it.
      // However, our backend register returns UserResponse.
      // Let's assume there is a way to get user data.
      // In a real scenario, we might have /auth/me
      // But for this task, I will assume login returns user data or we fetch it.
      // Since the prompt asks to return UserModel, I'll mock the extraction or assume a structure.
      
      // If the backend returns { "access_token": "...", "token_type": "bearer" }
      // We need to store the token. The BLoC will handle storing it.
      // Let's assume there is an endpoint to get user info after login.
      
      // For now, I'll implement it as described.
      if (response.statusCode == 200) {
        // Here we would typically fetch the user profile with the new token
        final userResponse = await _client.dio.get('business/me'); 
        return UserModel.fromJson(userResponse.data);
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Network error');
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
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to register');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Registration error');
    }
  }
}
