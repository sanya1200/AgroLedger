import 'package:equatable/equatable.dart';
import 'json_numeric.dart';

class PredictiveForecastModel extends Equatable {
  final int assetId;
  final double? fcr;
  final DateTime? breakEvenDate;
  final bool isProfitable;
  final double estimatedMonthlyProfit;
  final String advice;

  const PredictiveForecastModel({
    required this.assetId,
    this.fcr,
    this.breakEvenDate,
    required this.isProfitable,
    required this.estimatedMonthlyProfit,
    required this.advice,
  });

  factory PredictiveForecastModel.fromJson(Map<String, dynamic> json) {
    return PredictiveForecastModel(
      assetId: json['asset_id'],
      fcr: json['fcr'] != null ? parseJsonNumeric(json['fcr']) : null,
      breakEvenDate: json['break_even_date'] != null
          ? DateTime.parse(json['break_even_date'])
          : null,
      isProfitable: json['is_profitable'] ?? false,
      estimatedMonthlyProfit: parseJsonNumeric(json['estimated_monthly_profit']),
      advice: json['advice'] ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [assetId, fcr, breakEvenDate, isProfitable, estimatedMonthlyProfit, advice];
}
