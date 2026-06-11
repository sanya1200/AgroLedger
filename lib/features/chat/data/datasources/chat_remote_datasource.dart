import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/core/network/error_handler.dart';
import 'package:agroledger/features/chat/data/models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoom>> getRooms();
  Future<ChatRoom> getOrCreateRoom(int productId, int sellerId);
  Future<List<ChatMessage>> getRoomMessages(int roomId);
  WebSocketChannel connectToChatWebSocket();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  ChatRemoteDataSourceImpl(this._client, this._storage);

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
  Future<List<ChatRoom>> getRooms() async {
    try {
      final response = await _client.dio.get('chat/rooms');
      final data = _unwrap(response.data);
      return (data as List)
          .map((e) => ChatRoom.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка загрузки чатов');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChatRoom> getOrCreateRoom(int productId, int sellerId) async {
    try {
      final response = await _client.dio.post(
        'chat/rooms',
        queryParameters: {'product_id': productId, 'seller_id': sellerId},
      );
      final data = _unwrap(response.data);
      return ChatRoom.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка создания чата');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ChatMessage>> getRoomMessages(int roomId) async {
    try {
      final response = await _client.dio.get('chat/rooms/$roomId/messages');
      final data = _unwrap(response.data);
      return (data as List)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e, 'Ошибка загрузки сообщений');
    } catch (e) {
      rethrow;
    }
  }

  @override
  WebSocketChannel connectToChatWebSocket() {
    // The actual token logic needs to be handled before calling this, or synchronously if possible.
    // However, since connect is synchronous in WebSocketChannel.connect, we'll return a placeholder
    // or let the caller pass the token. Wait, we can't do async inside a synchronous method easily.
    // Let's modify the interface to accept the token.
    throw UnimplementedError('Use connectToChatWebSocketWithToken instead');
  }

  Future<WebSocketChannel> connectToChatWebSocketWithToken() async {
    final token = await _storage.read(key: 'auth_token');
    // Adjust to your actual backend WS URL. Assuming DioClient has baseUrl.
    final baseUrl = _client.dio.options.baseUrl.replaceFirst('http', 'ws');
    final wsUrl = '${baseUrl}chat/ws/$token';
    return WebSocketChannel.connect(Uri.parse(wsUrl));
  }
}
