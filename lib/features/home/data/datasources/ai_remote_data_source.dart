import 'package:dio/dio.dart';
import 'package:agroledger/core/network/dio_client.dart';

abstract class AiRemoteDataSource {
  Future<String> consultAi(String query);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final DioClient _dioClient;

  AiRemoteDataSourceImpl(this._dioClient);

  @override
  Future<String> consultAi(String query) async {
    try {
      final response = await _dioClient.dio.post(
        '/ai/consult',
        data: {'query': query},
      );
      return response.data['answer'] as String;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['detail'] ?? 'Ошибка соединения с ИИ');
      }
      throw Exception('Ошибка при обращении к серверу ИИ: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }
}
