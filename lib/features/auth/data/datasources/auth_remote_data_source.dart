import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/core/network/error_handler.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String identity, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    String? phone,
    required String role,
    String? fullName,
  });
  Future<UserModel> updateSettings({
    bool? isBiometricEnabled,
    String? fullName,
    String? phone,
    String? role,
  });
  Future<UserModel> verifyUser();
  Future<void> deleteAccount();
  Future<UserModel> getMe();
  Future<void> setupPin(String pinCode);
  Future<UserModel> googleSignIn({
    required String email,
    required String fullName,
    String? phone,
    String? role,
    String? idToken,
  });
  Future<void> verifyEmail(String email, String code);
  Future<void> resendVerificationCode(String email);
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
    String? phone,
    required String role,
    String? fullName,
  }) async {
    try {
      final response = await _client.dio.post(
        'auth/signup',
        data: {
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
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
  Future<UserModel> updateSettings({
    bool? isBiometricEnabled,
    String? fullName,
    String? phone,
    String? role,
  }) async {
    try {
      final response = await _client.dio.patch(
        'auth/update-settings',
        data: {
          if (isBiometricEnabled != null) 'is_biometric_enabled': isBiometricEnabled,
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (role != null) 'role': role,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        return UserModel.fromJson(Map<String, dynamic>.from(data['data']));
      } else {
        throw data?['error'] ?? 'Ошибка обновления настроек';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> verifyUser() async {
    try {
      final response = await _client.dio.post('auth/verify-user');
      final data = response.data;
      if (data != null && data['success'] == true) {
        return UserModel.fromJson(Map<String, dynamic>.from(data['data']));
      } else {
        throw data?['error'] ?? 'Ошибка верификации';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await _client.dio.delete('auth/delete-account');
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw data?['error'] ?? 'Ошибка удаления аккаунта';
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

  @override
  Future<void> setupPin(String pinCode) async {
    try {
      final response = await _client.dio.post(
        'auth/pin-setup',
        data: {
          'pin_code': pinCode,
        },
      );
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw data?['error'] ?? 'Ошибка сохранения ПИН-кода на сервере';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> googleSignIn({
    required String email,
    required String fullName,
    String? phone,
    String? role,
    String? idToken,
  }) async {
    try {
      final response = await _client.dio.post(
        'auth/google-signin',
        data: {
          'email': email,
          'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (role != null) 'role': role,
          if (idToken != null) 'id_token': idToken,
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
        throw data?['error'] ?? 'Ошибка входа через Google';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await _client.dio.post(
        'auth/verify-email',
        data: {
          'email': email,
          'code': code,
        },
      );
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw data?['error'] ?? 'Ошибка подтверждения email';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    try {
      final response = await _client.dio.post(
        'auth/resend-code',
        data: {
          'email': email,
        },
      );
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw data?['error'] ?? 'Ошибка отправки кода';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  String _handleDioError(DioException e) {
    return handleDioError(e, 'Ошибка авторизации');
  }
}
