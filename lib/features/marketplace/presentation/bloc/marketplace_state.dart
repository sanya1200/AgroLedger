import 'package:equatable/equatable.dart';
import 'package:agroledger/features/marketplace/data/models/product_model.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class ProductsLoadSuccess extends MarketplaceState {
  final List<ProductModel> products;

  const ProductsLoadSuccess(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductActionSuccess extends MarketplaceState {
  final String message;

  const ProductActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MarketplaceFailure extends MarketplaceState {
  final String message;

  const MarketplaceFailure(this.message);

  @override
  List<Object?> get props => [message];
}
