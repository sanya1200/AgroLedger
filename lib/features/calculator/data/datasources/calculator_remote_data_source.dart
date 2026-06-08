import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/calculator/data/models/calculation_cycle_model.dart';
import 'package:agroledger/features/calculator/data/models/expense_model.dart';
import 'package:agroledger/features/calculator/data/models/income_model.dart';
import 'package:agroledger/features/calculator/data/models/cycle_analytics_model.dart';

abstract class CalculatorRemoteDataSource {
  Future<List<CalculationCycleModel>> getCycles();
  Future<CalculationCycleModel> createCycle(String name, String animalType);
  Future<ExpenseModel> addExpense(int cycleId, String category, double amount, String? description);
  Future<IncomeModel> addIncome(int cycleId, String productName, double quantity, double amount);
  Future<CycleAnalyticsModel> getAnalytics(int cycleId);
  Future<CalculationCycleModel> closeCycle(int cycleId);
}

class CalculatorRemoteDataSourceImpl implements CalculatorRemoteDataSource {
  final DioClient _client;

  CalculatorRemoteDataSourceImpl(this._client);

  @override
  Future<List<CalculationCycleModel>> getCycles() async {
    final response = await _client.dio.get('calculator/cycles');
    return (response.data as List).map((e) => CalculationCycleModel.fromJson(e)).toList();
  }

  @override
  Future<CalculationCycleModel> createCycle(String name, String animalType) async {
    final response = await _client.dio.post('calculator/cycles', data: {
      'name': name,
      'animal_type': animalType,
    });
    return CalculationCycleModel.fromJson(response.data);
  }

  @override
  Future<ExpenseModel> addExpense(int cycleId, String category, double amount, String? description) async {
    final response = await _client.dio.post('calculator/cycles/$cycleId/expenses', data: {
      'category': category,
      'amount': amount,
      'description': description,
    });
    return ExpenseModel.fromJson(response.data);
  }

  @override
  Future<IncomeModel> addIncome(int cycleId, String productName, double quantity, double amount) async {
    final response = await _client.dio.post('calculator/cycles/$cycleId/incomes', data: {
      'product_name': productName,
      'quantity': quantity,
      'amount': amount,
    });
    return IncomeModel.fromJson(response.data);
  }

  @override
  Future<CycleAnalyticsModel> getAnalytics(int cycleId) async {
    final response = await _client.dio.get('calculator/cycles/$cycleId/analytics');
    return CycleAnalyticsModel.fromJson(response.data);
  }

  @override
  Future<CalculationCycleModel> closeCycle(int cycleId) async {
    final response = await _client.dio.put('calculator/cycles/$cycleId/close');
    return CalculationCycleModel.fromJson(response.data);
  }
}
