import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final int businessId;
  final String title;
  final String? description;
  final String category;
  final double priceRetail;
  final double? priceWholesale;
  final double wholesaleMinQty;
  final String? imageUrl;
  final double stockQuantity;
  final bool isActive;
  final DateTime createdAt;
  final String? sellerName;
  final String? sellerPhone;

  const ProductModel({
    required this.id,
    required this.businessId,
    required this.title,
    this.description,
    required this.category,
    required this.priceRetail,
    this.priceWholesale,
    required this.wholesaleMinQty,
    this.imageUrl,
    required this.stockQuantity,
    required this.isActive,
    required this.createdAt,
    this.sellerName,
    this.sellerPhone,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      priceRetail: double.parse(json['price_retail'].toString()),
      priceWholesale: json['price_wholesale'] != null 
          ? double.parse(json['price_wholesale'].toString()) 
          : null,
      wholesaleMinQty: double.parse(json['wholesale_min_qty'].toString()),
      imageUrl: json['image_url'] as String?,
      stockQuantity: double.parse(json['stock_quantity'].toString()),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      sellerName: json['seller_name'] as String?,
      sellerPhone: json['seller_phone'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        title,
        description,
        category,
        priceRetail,
        priceWholesale,
        wholesaleMinQty,
        imageUrl,
        stockQuantity,
        isActive,
        createdAt,
        sellerName,
        sellerPhone,
      ];
}
