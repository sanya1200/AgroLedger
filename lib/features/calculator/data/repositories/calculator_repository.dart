import '../datasources/calculator_remote_data_source.dart';
import '../models/livestock_asset_model.dart';
import '../models/livestock_expense_model.dart';
import '../models/livestock_yield_model.dart';
import '../models/calculator_summary_model.dart';
import '../models/predictive_forecast_model.dart';
import '../models/livestock_task_model.dart';

class CalculatorRepository {
  final CalculatorRemoteDataSource _remoteDataSource;

  CalculatorRepository(this._remoteDataSource);

  Future<List<LivestockAssetModel>> getAssets() async {
    return await _remoteDataSource.getAssets();
  }

  Future<LivestockAssetModel> addAsset(LivestockAssetModel asset) async {
    return await _remoteDataSource.createAsset(asset.toCreateJson());
  }

  Future<void> addExpense(LivestockExpenseModel expense) async {
    return await _remoteDataSource.addExpense(expense.toJson());
  }

  Future<void> addYield(LivestockYieldModel yieldData) async {
    return await _remoteDataSource.addYield(yieldData.toJson());
  }

  Future<CalculatorSummaryModel> getSummary({int? assetId}) async {
    return await _remoteDataSource.getSummary(assetId: assetId);
  }

  Future<PredictiveForecastModel> getPredictiveForecast(int assetId) async {
    return await _remoteDataSource.getPredictiveForecast(assetId);
  }

  Future<void> activatePremiumDebug() async {
    return await _remoteDataSource.activatePremiumDebug();
  }

  Future<List<LivestockTaskModel>> getTasks() async {
    return await _remoteDataSource.getTasks();
  }

  Future<LivestockTaskModel> addTask(LivestockTaskModel task) async {
    return await _remoteDataSource.createTask(task.toJson());
  }

  Future<LivestockTaskModel> updateTask(int taskId, LivestockTaskModel task) async {
    return await _remoteDataSource.updateTask(taskId, task.toJson());
  }

  Future<void> deleteTask(int taskId) async {
    return await _remoteDataSource.deleteTask(taskId);
  }
}
