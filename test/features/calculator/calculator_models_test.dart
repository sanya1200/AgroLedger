import 'package:flutter_test/flutter_test.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_expense_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_yield_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';
import 'package:agroledger/features/calculator/domain/services/report_export_service.dart';
import 'package:agroledger/features/calculator/data/models/calculator_enums.dart';

void main() {
  group('LivestockAssetModel', () {
    test('fromJson parses numeric strings safely', () {
      final model = LivestockAssetModel.fromJson(const {
        'id': 1,
        'category': 'poultry_layers',
        'breed': 'Бройлер',
        'quantity': 500,
        'purchase_price': '125000.50',
        'created_at': '2026-06-10T12:00:00Z',
      });

      expect(model.id, 1);
      expect(model.category, 'poultry_layers');
      expect(model.purchasePrice, 125000.50);
      expect(model.createdAt, isNotNull);
    });

    test('toCreateJson sends only create fields', () {
      const model = LivestockAssetModel(
        category: 'cattle_meat',
        breed: 'Ангус',
        quantity: 20,
        purchasePrice: 800000,
      );

      expect(model.toCreateJson(), {
        'category': 'cattle_meat',
        'breed': 'Ангус',
        'quantity': 20.0,
        'purchase_price': 800000.0,
      });
    });
  });

  group('LivestockExpenseModel', () {
    test('fromJson parses sub-types correctly', () {
      final model = LivestockExpenseModel.fromJson(const {
        'id': 2,
        'asset_id': 1,
        'feed_sub_type': 'compound_feed',
        'amount': '14500.75',
        'date': '2026-06-10T08:30:00Z',
      });

      expect(model.amount, 14500.75);
      expect(model.feedSubType, FeedSubType.compoundFeed);
      expect(model.totalCost, 14500.75);
    });
  });

  group('LivestockYieldModel', () {
    test('fromJson parses product sub-type and earnings', () {
      final model = LivestockYieldModel.fromJson(const {
        'id': 3,
        'asset_id': 1,
        'product_sub_type': 'eggs_commercial',
        'volume': '1200',
        'earnings': '48000.00',
        'date': '2026-06-10T18:00:00Z',
      });

      expect(model.productSubType, ProductSubType.eggsCommercial);
      expect(model.volume, 1200);
      expect(model.earnings, 48000);
    });
  });

  group('CalculatorSummaryModel', () {
    test('fromJson parses earnings_by_product and expense breakdown', () {
      final model = CalculatorSummaryModel.fromJson(const {
        'asset_id': null,
        'assets_count': 2,
        'initial_investment': '150000',
        'total_feed_cost': '45000',
        'total_vet_cost': '8000',
        'total_utility_cost': '12000',
        'total_other_cost': '3000',
        'operating_expenses': '68000',
        'total_costs': '218000',
        'total_earnings': '285000',
        'net_profit': '67000',
        'roi': 30.73,
        'earnings_by_product': {
          'eggs_commercial': '120000',
          'meat_carcass': '165000',
        },
      });

      expect(model.assetsCount, 2);
      expect(model.feedCost, 45000);
      expect(model.vetCost, 8000);
      expect(model.netProfit, 67000);
      expect(model.roi, 30.73);
      expect(model.earningsByProduct['eggs_commercial'], 120000);
      expect(model.earningsByProduct['meat_carcass'], 165000);
    });
  });

  group('ReportExportService', () {
    test('buildCsv contains financial sections', () {
      const summary = CalculatorSummaryModel(
        assetsCount: 2,
        initialInvestment: 150000,
        feedCost: 45000,
        vetCost: 8000,
        utilityCost: 12000,
        otherCost: 3000,
        operatingExpenses: 68000,
        totalCosts: 218000,
        totalEarnings: 285000,
        netProfit: 67000,
        roi: 30.73,
        earningsByProduct: {
          'eggs_commercial': 120000,
          'meat_carcass': 165000,
        },
      );

      final csv = ReportExportService().buildCsv(summary);

      expect(csv, contains('AgroLedger'));
      expect(csv, contains('Чистая прибыль'));
      expect(csv, contains('Корма'));
    });
  });
}
