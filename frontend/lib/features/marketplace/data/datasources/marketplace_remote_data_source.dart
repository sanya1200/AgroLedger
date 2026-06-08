import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/marketplace/data/models/product_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? category});
  Future<ProductModel> createProduct(Map<String, dynamic> productData);
  Future<void> deleteProduct(int productId);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final DioClient _client;

  MarketplaceRemoteDataSourceImpl(this._client);

  @override
  Future<List<ProductModel>> getProducts({String? category}) async {
    final response = await _client.dio.get(
      'marketplace/products',
      queryParameters: category != null ? {'category': category} : null,
    );
    return (response.data as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    final response = await _client.dio.post(
      'marketplace/products',
      data: productData,
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    await _client.dio.delete('marketplace/products/$productId');
  }
}
