import 'package:equatable/equatable.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsRequested extends MarketplaceEvent {
  final String? category;

  const LoadProductsRequested({this.category});

  @override
  List<Object?> get props => [category];
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
