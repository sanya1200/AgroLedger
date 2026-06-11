import 'package:dio/dio.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/core/network/error_handler.dart';
import 'package:agroledger/features/marketplace/data/models/product_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? category});
  Future<ProductModel> createProduct(Map<String, dynamic> productData);
  Future<void> deleteProduct(int productId);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final DioClient _client;

  MarketplaceRemoteDataSourceImpl(this._client);

  dynamic _unwrap(dynamic responseData) {
    if (responseData is Map) {
      if (responseData['success'] == true) {
        return responseData['data'];
      }
      throw responseData['error'] ?? 'Ошибка сервера';
    }
    return responseData;
  }

  @override
  Future<List<ProductModel>> getProducts({String? category}) async {
    try {
      final response = await _client.dio.get(
        'marketplace/products',
        queryParameters: category != null ? {'category': category} : null,
      );
      final data = _unwrap(response.data);
      return (data as List)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка загрузки каталога');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _client.dio.post(
        'marketplace/products',
        data: productData,
      );
      final data = _unwrap(response.data);
      return ProductModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка добавления товара');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int productId) async {
    try {
      final response = await _client.dio.delete('marketplace/products/$productId');
      _unwrap(response.data);
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка удаления товара');
    } catch (e) {
      rethrow;
    }
  }
}
