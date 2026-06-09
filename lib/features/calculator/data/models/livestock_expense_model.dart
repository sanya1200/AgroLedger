import 'package:equatable/equatable.dart';
import 'package:agroledger/features/calculator/data/models/json_numeric.dart';

class LivestockExpenseModel extends Equatable {
  final int? id;
  final int assetId;
  final double feedCost;
  final double vetCost;
  final double utilityCost;
  final double otherCost;
  final DateTime date;

  const LivestockExpenseModel({
    this.id,
    required this.assetId,
    required this.feedCost,
    required this.vetCost,
    required this.utilityCost,
    required this.otherCost,
    required this.date,
  });

  double get totalCost => feedCost + vetCost + utilityCost + otherCost;

  factory LivestockExpenseModel.fromJson(Map<String, dynamic> json) {
    return LivestockExpenseModel(
      id: json['id'] != null ? parseJsonInt(json['id']) : null,
      assetId: parseJsonInt(json['asset_id']),
      feedCost: parseJsonNumeric(json['feed_cost']),
      vetCost: parseJsonNumeric(json['vet_cost']),
      utilityCost: parseJsonNumeric(json['utility_cost']),
      otherCost: parseJsonNumeric(json['other_cost']),
      date: DateTime.parse(json['date'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'asset_id': assetId,
      'feed_cost': feedCost,
      'vet_cost': vetCost,
      'utility_cost': utilityCost,
      'other_cost': otherCost,
      'date': date.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'asset_id': assetId,
      'feed_cost': feedCost,
      'vet_cost': vetCost,
      'utility_cost': utilityCost,
      'other_cost': otherCost,
      'date': date.toIso8601String(),
    };
  }

  LivestockExpenseModel copyWith({
    int? id,
    int? assetId,
    double? feedCost,
    double? vetCost,
    double? utilityCost,
    double? otherCost,
    DateTime? date,
  }) {
    return LivestockExpenseModel(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      feedCost: feedCost ?? this.feedCost,
      vetCost: vetCost ?? this.vetCost,
      utilityCost: utilityCost ?? this.utilityCost,
      otherCost: otherCost ?? this.otherCost,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [
        id,
        assetId,
        feedCost,
        vetCost,
        utilityCost,
        otherCost,
        date,
      ];
}
