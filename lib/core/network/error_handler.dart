import 'package:dio/dio.dart';
import 'dart:developer' as dev;

String handleDioError(DioException e, String defaultMessage) {
  dev.log('DioError: ${e.type}', error: e, name: 'DioErrorHandler');
  if (e.response != null) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['error'] != null) return data['error'].toString();
      
      final detail = data['detail'];
      if (detail is List) {
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
