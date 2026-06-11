import 'package:equatable/equatable.dart';
import 'calculator_enums.dart';
import 'json_numeric.dart';

class LivestockExpenseModel extends Equatable {
  final int? id;
  final int assetId;
  final FeedSubType? feedSubType;
  final VetSubType? vetSubType;
  final UtilitySubType? utilitySubType;
  final OtherSubType? otherSubType;
  final double amount;
  final String? description;
  final DateTime? date;

  const LivestockExpenseModel({
    this.id,
    required this.assetId,
    this.feedSubType,
    this.vetSubType,
    this.utilitySubType,
    this.otherSubType,
    required this.amount,
    this.description,
    this.date,
  });

  factory LivestockExpenseModel.fromJson(Map<String, dynamic> json) {
    return LivestockExpenseModel(
      id: json['id'],
      assetId: json['asset_id'],
      feedSubType: json['feed_sub_type'] != null
          ? FeedSubType.fromString(json['feed_sub_type'])
          : null,
      vetSubType: json['vet_sub_type'] != null
          ? VetSubType.fromString(json['vet_sub_type'])
          : null,
      utilitySubType: json['utility_sub_type'] != null
          ? UtilitySubType.fromString(json['utility_sub_type'])
          : null,
      otherSubType: json['other_sub_type'] != null
          ? OtherSubType.fromString(json['other_sub_type'])
          : null,
      amount: parseJsonNumeric(json['amount']),
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        if (feedSubType != null) 'feed_sub_type': feedSubType!.name,
        if (vetSubType != null) 'vet_sub_type': vetSubType!.name,
        if (utilitySubType != null) 'utility_sub_type': utilitySubType!.name,
        if (otherSubType != null) 'other_sub_type': otherSubType!.name,
        'amount': amount,
        if (description != null) 'description': description,
        'date': date?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        assetId,
        feedSubType,
        vetSubType,
        utilitySubType,
        otherSubType,
        amount,
        description,
        date
      ];

  double get totalCost => amount;
}
