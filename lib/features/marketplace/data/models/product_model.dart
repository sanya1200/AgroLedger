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
  final DateTime? createdAt;
  final String? sellerName;
  final String? sellerPhone;
  final int? sellerId;

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
    this.createdAt,
    this.sellerName,
    this.sellerPhone,
    this.sellerId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      businessId: json['business_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Без названия',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'other',
      priceRetail: double.tryParse(json['price_retail']?.toString() ?? '0') ?? 0.0,
      priceWholesale: json['price_wholesale'] != null 
          ? double.tryParse(json['price_wholesale'].toString()) 
          : null,
      wholesaleMinQty: double.tryParse(json['wholesale_min_qty']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url'] as String?,
      stockQuantity: double.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      sellerName: json['seller_name'] as String?,
      sellerPhone: json['seller_phone'] as String?,
      sellerId: json['seller_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'title': title,
      'description': description,
      'category': category,
      'price_retail': priceRetail,
      'price_wholesale': priceWholesale,
      'wholesale_min_qty': wholesaleMinQty,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'seller_id': sellerId,
    };
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
        sellerId,
      ];
}
