import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRemoteDataSource _dataSource;

  MarketplaceBloc(this._dataSource) : super(MarketplaceInitial()) {
    on<LoadProductsRequested>(_onLoadProducts);
    on<CreateProductRequested>(_onCreateProduct);
    on<DeleteProductRequested>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadProductsRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(MarketplaceLoading());
    try {
      final products = await _dataSource.getProducts(category: event.category);
      emit(ProductsLoadSuccess(products));
    } catch (e) {
      emit(MarketplaceFailure(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
    CreateProductRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(MarketplaceLoading());
    try {
      await _dataSource.createProduct(event.productData);
      emit(const ProductActionSuccess('Товар успешно добавлен'));
      add(const LoadProductsRequested());
    } catch (e) {
      emit(MarketplaceFailure(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(MarketplaceLoading());
    try {
      await _dataSource.deleteProduct(event.productId);
      emit(const ProductActionSuccess('Товар снят с публикации'));
      add(const LoadProductsRequested());
    } catch (e) {
      emit(MarketplaceFailure(e.toString()));
    }
  }
}
