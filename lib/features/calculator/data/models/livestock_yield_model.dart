import 'package:equatable/equatable.dart';
import 'package:agroledger/features/calculator/data/models/json_numeric.dart';

class LivestockYieldModel extends Equatable {
  final int? id;
  final int assetId;
  final String productType;
  final double volume;
  final double earnings;
  final DateTime date;

  const LivestockYieldModel({
    this.id,
    required this.assetId,
    required this.productType,
    required this.volume,
    required this.earnings,
    required this.date,
  });

  factory LivestockYieldModel.fromJson(Map<String, dynamic> json) {
    return LivestockYieldModel(
      id: json['id'] != null ? parseJsonInt(json['id']) : null,
      assetId: parseJsonInt(json['asset_id']),
      productType: json['product_type']?.toString() ?? '',
      volume: parseJsonNumeric(json['volume']),
      earnings: parseJsonNumeric(json['earnings']),
      date: DateTime.parse(json['date'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'asset_id': assetId,
      'product_type': productType,
      'volume': volume,
      'earnings': earnings,
      'date': date.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'asset_id': assetId,
      'product_type': productType,
      'volume': volume,
      'earnings': earnings,
      'date': date.toIso8601String(),
    };
  }

  LivestockYieldModel copyWith({
    int? id,
    int? assetId,
    String? productType,
    double? volume,
    double? earnings,
    DateTime? date,
  }) {
    return LivestockYieldModel(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      productType: productType ?? this.productType,
      volume: volume ?? this.volume,
      earnings: earnings ?? this.earnings,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [id, assetId, productType, volume, earnings, date];
}
