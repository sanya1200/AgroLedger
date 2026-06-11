import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/core/services/auth_session_service.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final AuthSessionService _sessionService;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  static const _deviceFingerprint = 'agro_device_id_default';
  static const _deviceName = 'Mobile App';

  DioClient(
    this._dio,
    this._storage,
    this._sessionService,
  ) {
    _dio
      ..options.baseUrl = 'https://agroledger-zlxo.onrender.com/api/v1/'
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await _storage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            if (_isNetworkError(e)) {
              if (e.requestOptions.extra['retry_count'] == null) {
                e.requestOptions.extra['retry_count'] = 0;
              }
              final retryCount = e.requestOptions.extra['retry_count'] as int;
              if (retryCount < 2) {
                e.requestOptions.extra['retry_count'] = retryCount + 1;
                await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
                try {
                  final retryResponse = await _dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                } catch (retryError) {
                  if (retryError is DioException) {
                    e = retryError;
                  }
                }
              }
            }

            if (!_shouldAttemptRefresh(e)) {
              return handler.next(e);
            }

            final refreshed = await _refreshTokens();
            if (refreshed) {
              try {
                final newToken = await _storage.read(key: 'access_token');
                final options = e.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await _dio.fetch(options);
                return handler.resolve(retryResponse);
              } catch (retryError) {
                if (retryError is DioException) {
                  return handler.next(retryError);
                }
                return handler.next(e);
              }
            }

            await _clearAuthStorage();
            _sessionService.notifySessionExpired();
            return handler.next(e);
          },
        ),
      );
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown;
  }

  bool _shouldAttemptRefresh(DioException e) {
    if (e.response?.statusCode != 401) return false;

    final path = e.requestOptions.path;
    if (path.contains('auth/signin') ||
        path.contains('auth/signup') ||
        path.contains('auth/refresh')) {
      return false;
    }
    return true;
  }

  Future<bool> _refreshTokens() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Device-Fingerprint': _deviceFingerprint,
            'X-Device-Name': _deviceName,
          },
        ),
      );

      final response = await refreshDio.post(
        'auth/refresh',
        queryParameters: {'refresh_token': refreshToken},
      );

      if (response.data is Map && response.data['success'] == true) {
        final tokenData = response.data['data'] as Map<String, dynamic>;
        await _storage.write(
          key: 'access_token',
          value: tokenData['access_token'] as String,
        );
        await _storage.write(
          key: 'refresh_token',
          value: tokenData['refresh_token'] as String,
        );
        _refreshCompleter!.complete(true);
        return true;
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<void> _clearAuthStorage() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Dio get dio => _dio;
}
