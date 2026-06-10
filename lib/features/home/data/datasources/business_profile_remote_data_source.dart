import 'package:agroledger/core/network/dio_client.dart';

abstract class BusinessProfileRemoteDataSource {
  Future<Map<String, dynamic>> getMyProfile();
  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
}

class BusinessProfileRemoteDataSourceImpl implements BusinessProfileRemoteDataSource {
  final DioClient _client;

  BusinessProfileRemoteDataSourceImpl(this._client);

  dynamic _unwrap(dynamic responseData) {
    if (responseData is Map && responseData['success'] == true) {
      return responseData['data'];
    }
    throw responseData?['error'] ?? 'Ошибка сервера';
  }

  @override
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _client.dio.get('business/me');
      return Map<String, dynamic>.from(_unwrap(response.data));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data) async {
    final response = await _client.dio.post('business/', data: data);
    return Map<String, dynamic>.from(_unwrap(response.data));
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.dio.patch('business/', data: data);
    return Map<String, dynamic>.from(_unwrap(response.data));
  }
}
