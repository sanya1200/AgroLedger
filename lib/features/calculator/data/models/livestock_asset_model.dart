import 'package:equatable/equatable.dart';
import 'package:agroledger/features/calculator/data/models/json_numeric.dart';

class LivestockAssetModel extends Equatable {
  final int? id;
  final String category;
  final String breed;
  final double quantity;
  final double purchasePrice;
  final DateTime? createdAt;

  const LivestockAssetModel({
    this.id,
    required this.category,
    required this.breed,
    required this.quantity,
    required this.purchasePrice,
    this.createdAt,
  });

  factory LivestockAssetModel.fromJson(Map<String, dynamic> json) {
    return LivestockAssetModel(
      id: json['id'] != null ? parseJsonInt(json['id']) : null,
      category: json['category']?.toString() ?? '',
      breed: json['breed']?.toString() ?? '',
      quantity: parseJsonNumeric(json['quantity']),
      purchasePrice: parseJsonNumeric(json['purchase_price']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'breed': breed,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'category': category,
      'breed': breed,
      'quantity': quantity,
      'purchase_price': purchasePrice,
    };
  }

  LivestockAssetModel copyWith({
    int? id,
    String? category,
    String? breed,
    double? quantity,
    double? purchasePrice,
    DateTime? createdAt,
  }) {
    return LivestockAssetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      breed: breed ?? this.breed,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, category, breed, quantity, purchasePrice, createdAt];
}
