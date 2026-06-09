import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_expense_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_yield_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';

class CalculatorRepository {
  final DioClient _client;

  CalculatorRepository(this._client);

  Future<List<LivestockAssetModel>> getAssets() async {
    try {
      final response = await _client.dio.get('calculator/assets');
      final data = _unwrapResponse(response.data);
      final list = data as List;
      return list
          .map((item) => LivestockAssetModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> addAsset(LivestockAssetModel asset) async {
    try {
      final response = await _client.dio.post(
        'calculator/assets',
        data: asset.toCreateJson(),
      );
      _unwrapResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> addExpense(LivestockExpenseModel expense) async {
    try {
      final response = await _client.dio.post(
        'calculator/expenses',
        data: expense.toCreateJson(),
      );
      _unwrapResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> addYield(LivestockYieldModel yieldData) async {
    try {
      final response = await _client.dio.post(
        'calculator/yields',
        data: yieldData.toCreateJson(),
      );
      _unwrapResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<CalculatorSummaryModel> getSummary({int? assetId}) async {
    try {
      final response = await _client.dio.get(
        'calculator/summary',
        queryParameters: assetId != null ? {'asset_id': assetId} : null,
      );
      final data = _unwrapResponse(response.data);
      return CalculatorSummaryModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _unwrapResponse(dynamic responseData) {
    if (responseData is! Map) {
      throw 'Некорректный формат ответа сервера';
    }

    final success = responseData['success'];
    if (success == true) {
      return responseData['data'];
    }

    final error = responseData['error'];
    throw error?.toString() ?? 'Ошибка сервера';
  }

  String _handleDioError(DioException e) {
    dev.log('DioError: ${e.type}', error: e, name: 'CalculatorRepository');
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
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Превышено время ожидания';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Сервер отвечает слишком долго';
    }
    return 'Проблемы с интернет-соединением';
  }
}
