import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';
import 'package:agroledger/features/calculator/data/models/predictive_forecast_model.dart';

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
    final response = await _client.dio.get('calculator/assets');
    final data = _unwrap(response.data);
    return (data as List)
        .map((e) => LivestockAssetModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<LivestockAssetModel> createAsset(Map<String, dynamic> assetData) async {
    final response = await _client.dio.post('calculator/assets', data: assetData);
    final data = _unwrap(response.data);
    return LivestockAssetModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    final response = await _client.dio.post('calculator/expenses', data: expenseData);
    _unwrap(response.data);
  }

  @override
  Future<void> addYield(Map<String, dynamic> yieldData) async {
    final response = await _client.dio.post('calculator/yields', data: yieldData);
    _unwrap(response.data);
  }

  @override
  Future<CalculatorSummaryModel> getSummary({int? assetId}) async {
    final response = await _client.dio.get(
      'calculator/summary',
      queryParameters: assetId != null ? {'asset_id': assetId} : null,
    );
    final data = _unwrap(response.data);
    return CalculatorSummaryModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<PredictiveForecastModel> getPredictiveForecast(int assetId) async {
    final response = await _client.dio.get(
      'calculator/predictive-forecast',
      queryParameters: {'asset_id': assetId},
    );
    final data = _unwrap(response.data);
    return PredictiveForecastModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> activatePremiumDebug() async {
    final response = await _client.dio.post('auth/activate-premium');
    _unwrap(response.data);
  }
}
