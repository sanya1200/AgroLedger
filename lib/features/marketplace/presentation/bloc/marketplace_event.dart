import 'package:equatable/equatable.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsRequested extends MarketplaceEvent {
  final String? category;
  final String? search;
  final double? minPrice;
  final double? maxPrice;

  const LoadProductsRequested({
    this.category,
    this.search,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [category, search, minPrice, maxPrice];
}

class CreateProductRequested extends MarketplaceEvent {
  final Map<String, dynamic> productData;

  const CreateProductRequested(this.productData);

  @override
  List<Object?> get props => [productData];
}

class DeleteProductRequested extends MarketplaceEvent {
  final int productId;

  const DeleteProductRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}
