import 'package:equatable/equatable.dart';
import 'package:agroledger/features/calculator/data/models/json_numeric.dart';

class CalculatorSummaryModel extends Equatable {
  final int? assetId;
  final int assetsCount;
  final double initialInvestment;
  final double feedCost;
  final double vetCost;
  final double utilityCost;
  final double otherCost;
  final double operatingExpenses;
  final double totalCosts;
  final double totalEarnings;
  final double netProfit;
  final double roi;
  final Map<String, double> earningsByProduct;

  const CalculatorSummaryModel({
    this.assetId,
    required this.assetsCount,
    required this.initialInvestment,
    required this.feedCost,
    required this.vetCost,
    required this.utilityCost,
    required this.otherCost,
    required this.operatingExpenses,
    required this.totalCosts,
    required this.totalEarnings,
    required this.netProfit,
    required this.roi,
    required this.earningsByProduct,
  });

  factory CalculatorSummaryModel.fromJson(Map<String, dynamic> json) {
    return CalculatorSummaryModel(
      assetId: json['asset_id'] != null ? parseJsonInt(json['asset_id']) : null,
      assetsCount: parseJsonInt(json['assets_count']),
      initialInvestment: parseJsonNumeric(json['initial_investment']),
      feedCost: parseJsonNumeric(json['total_feed_cost']),
      vetCost: parseJsonNumeric(json['total_vet_cost']),
      utilityCost: parseJsonNumeric(json['total_utility_cost']),
      otherCost: parseJsonNumeric(json['total_other_cost']),
      operatingExpenses: parseJsonNumeric(json['operating_expenses']),
      totalCosts: parseJsonNumeric(json['total_costs']),
      totalEarnings: parseJsonNumeric(json['total_earnings']),
      netProfit: parseJsonNumeric(json['net_profit']),
      roi: parseJsonNumeric(json['roi']),
      earningsByProduct: parseEarningsByProduct(
        json['earnings_by_product'] != null
            ? Map<String, dynamic>.from(json['earnings_by_product'] as Map)
            : null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (assetId != null) 'asset_id': assetId,
      'assets_count': assetsCount,
      'initial_investment': initialInvestment,
      'total_feed_cost': feedCost,
      'total_vet_cost': vetCost,
      'total_utility_cost': utilityCost,
      'total_other_cost': otherCost,
      'operating_expenses': operatingExpenses,
      'total_costs': totalCosts,
      'total_earnings': totalEarnings,
      'net_profit': netProfit,
      'roi': roi,
      'earnings_by_product': earningsByProduct,
    };
  }

  CalculatorSummaryModel copyWith({
    int? assetId,
    int? assetsCount,
    double? initialInvestment,
    double? feedCost,
    double? vetCost,
    double? utilityCost,
    double? otherCost,
    double? operatingExpenses,
    double? totalCosts,
    double? totalEarnings,
    double? netProfit,
    double? roi,
    Map<String, double>? earningsByProduct,
  }) {
    return CalculatorSummaryModel(
      assetId: assetId ?? this.assetId,
      assetsCount: assetsCount ?? this.assetsCount,
      initialInvestment: initialInvestment ?? this.initialInvestment,
      feedCost: feedCost ?? this.feedCost,
      vetCost: vetCost ?? this.vetCost,
      utilityCost: utilityCost ?? this.utilityCost,
      otherCost: otherCost ?? this.otherCost,
      operatingExpenses: operatingExpenses ?? this.operatingExpenses,
      totalCosts: totalCosts ?? this.totalCosts,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      netProfit: netProfit ?? this.netProfit,
      roi: roi ?? this.roi,
      earningsByProduct: earningsByProduct ?? this.earningsByProduct,
    );
  }

  @override
  List<Object?> get props => [
        assetId,
        assetsCount,
        initialInvestment,
        feedCost,
        vetCost,
        utilityCost,
        otherCost,
        operatingExpenses,
        totalCosts,
        totalEarnings,
        netProfit,
        roi,
        earningsByProduct,
      ];
}
