import 'package:equatable/equatable.dart';
import 'calculator_enums.dart';
import 'json_numeric.dart';

class LivestockYieldModel extends Equatable {
  final int? id;
  final int assetId;
  final ProductSubType productSubType;
  final double volume;
  final double earnings;
  final DateTime date;

  const LivestockYieldModel({
    this.id,
    required this.assetId,
    required this.productSubType,
    required this.volume,
    required this.earnings,
    required this.date,
  });

  factory LivestockYieldModel.fromJson(Map<String, dynamic> json) {
    return LivestockYieldModel(
      id: json['id'],
      assetId: json['asset_id'],
      productSubType: ProductSubType.fromString(json['product_sub_type']),
      volume: parseJsonNumeric(json['volume']),
      earnings: parseJsonNumeric(json['earnings']),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        'product_sub_type': productSubType.name,
        'volume': volume,
        'earnings': earnings,
        'date': date.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, assetId, productSubType, volume, earnings, date];
}
