import 'package:flutter_test/flutter_test.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';

void main() {
  group('CalculatorSummaryModel', () {
    test('fromJson parses string decimals correctly to double', () {
      final Map<String, dynamic> jsonResponse = {
        'asset_id': 1,
        'assets_count': 5,
        'initial_investment': '1000.50',
        'total_feed_cost': '100.25',
        'total_vet_cost': '50.75',
        'total_utility_cost': '0.0',
        'total_other_cost': '0.0',
        'operating_expenses': '151.00',
        'total_costs': '1151.50',
        'total_earnings': '1500.00',
        'earnings_by_product': {'meat': '1500.00'},
        'net_profit': '348.50',
        'roi': 30.26
      };

      final model = CalculatorSummaryModel.fromJson(jsonResponse);

      expect(model.initialInvestment, 1000.50);
      expect(model.feedCost, 100.25);
      expect(model.vetCost, 50.75);
      expect(model.utilityCost, 0.0);
      expect(model.otherCost, 0.0);
      expect(model.operatingExpenses, 151.0);
      expect(model.totalCosts, 1151.50);
      expect(model.totalEarnings, 1500.0);
      expect(model.netProfit, 348.50);
      expect(model.roi, 30.26);
      expect(model.earningsByProduct, {'meat': 1500.0});
    });

    test('fromJson handles numeric (non-string) decimals safely', () {
      final Map<String, dynamic> jsonResponse = {
        'asset_id': 1,
        'assets_count': 5,
        'initial_investment': 1000.50,
        'total_feed_cost': 100.25,
        'total_vet_cost': 50.75,
        'total_utility_cost': 0,
        'total_other_cost': 0,
        'operating_expenses': 151,
        'total_costs': 1151.5,
        'total_earnings': 1500,
        'earnings_by_product': {'meat': 1500},
        'net_profit': 348.5,
        'roi': 30.26
      };

      final model = CalculatorSummaryModel.fromJson(jsonResponse);

      expect(model.initialInvestment, 1000.50);
      expect(model.operatingExpenses, 151.0);
      expect(model.utilityCost, 0.0);
    });
  });
}
