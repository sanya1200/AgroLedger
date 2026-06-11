import 'package:dio/dio.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/core/network/error_handler.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';
import 'package:agroledger/features/calculator/data/models/predictive_forecast_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_task_model.dart';

class FreeLimitException implements Exception {}
class PremiumRequiredException implements Exception {}

abstract class CalculatorRemoteDataSource {
  Future<List<LivestockAssetModel>> getAssets();
  Future<LivestockAssetModel> createAsset(Map<String, dynamic> assetData);
  Future<void> addExpense(Map<String, dynamic> expenseData);
  Future<void> addYield(Map<String, dynamic> yieldData);
  Future<CalculatorSummaryModel> getSummary({int? assetId});
  Future<PredictiveForecastModel> getPredictiveForecast(int assetId);
  Future<void> activatePremiumDebug();
  
  // Veterinary & Breeding Tasks
  Future<List<LivestockTaskModel>> getTasks();
  Future<LivestockTaskModel> createTask(Map<String, dynamic> taskData);
  Future<LivestockTaskModel> updateTask(int taskId, Map<String, dynamic> taskData);
  Future<void> deleteTask(int taskId);
}

class CalculatorRemoteDataSourceImpl implements CalculatorRemoteDataSource {
  final DioClient _client;

  CalculatorRemoteDataSourceImpl(this._client);

  dynamic _unwrap(dynamic responseData) {
    if (responseData is Map && responseData['success'] == true) {
      return responseData['data'];
    }
    final error = responseData?['error'];
    if (error == 'FREE_LIMIT_REACHED') throw FreeLimitException();
    if (error == 'PREMIUM_REQUIRED') throw PremiumRequiredException();
    
    throw error ?? 'Ошибка сервера';
  }

  @override
  Future<List<LivestockAssetModel>> getAssets() async {
    try {
      final response = await _client.dio.get('calculator/assets');
      final data = _unwrap(response.data);
      return (data as List)
          .map((e) => LivestockAssetModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка загрузки групп поголовья');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LivestockAssetModel> createAsset(Map<String, dynamic> assetData) async {
    try {
      final response = await _client.dio.post('calculator/assets', data: assetData);
      final data = _unwrap(response.data);
      return LivestockAssetModel.fromJson(Map<String, dynamic>.from(data));
    } on FreeLimitException {
      rethrow;
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка добавления группы поголовья');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await _client.dio.post('calculator/expenses', data: expenseData);
      _unwrap(response.data);
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка добавления расхода');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addYield(Map<String, dynamic> yieldData) async {
    try {
      final response = await _client.dio.post('calculator/yields', data: yieldData);
      _unwrap(response.data);
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка добавления дохода');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CalculatorSummaryModel> getSummary({int? assetId}) async {
    try {
      final response = await _client.dio.get(
        'calculator/summary',
        queryParameters: assetId != null ? {'asset_id': assetId} : null,
      );
      final data = _unwrap(response.data);
      return CalculatorSummaryModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка загрузки сводки калькулятора');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PredictiveForecastModel> getPredictiveForecast(int assetId) async {
    try {
      final response = await _client.dio.get(
        'calculator/predictive-forecast',
        queryParameters: {'asset_id': assetId},
      );
      final data = _unwrap(response.data);
      return PredictiveForecastModel.fromJson(Map<String, dynamic>.from(data));
    } on PremiumRequiredException {
      rethrow;
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка загрузки прогноза');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> activatePremiumDebug() async {
    try {
      final response = await _client.dio.post('auth/activate-premium');
      _unwrap(response.data);
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка активации премиума');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<LivestockTaskModel>> getTasks() async {
    try {
      final response = await _client.dio.get('calendar/tasks');
      final data = _unwrap(response.data);
      return (data as List)
          .map((e) => LivestockTaskModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка получения задач календаря');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LivestockTaskModel> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _client.dio.post('calendar/tasks', data: taskData);
      final data = _unwrap(response.data);
      return LivestockTaskModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка создания календарной задачи');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LivestockTaskModel> updateTask(int taskId, Map<String, dynamic> taskData) async {
    try {
      final response = await _client.dio.patch('calendar/tasks/$taskId', data: taskData);
      final data = _unwrap(response.data);
      return LivestockTaskModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка обновления календарной задачи');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    try {
      final response = await _client.dio.delete('calendar/tasks/$taskId');
      _unwrap(response.data);
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка удаления календарной задачи');
    } catch (e) {
      rethrow;
    }
  }
}
