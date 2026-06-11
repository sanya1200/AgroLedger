import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:agroledger/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_event.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_state.dart';
import 'package:agroledger/features/chat/data/models/chat_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRemoteDataSourceImpl _dataSource;
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  List<ChatMessage> _currentMessages = [];

  ChatBloc(this._dataSource) : super(ChatInitial()) {
    on<LoadRoomsRequested>(_onLoadRooms);
    on<CreateRoomRequested>(_onCreateRoom);
    on<LoadMessagesRequested>(_onLoadMessages);
    on<ConnectWebSocketRequested>(_onConnectWebSocket);
    on<DisconnectWebSocketRequested>(_onDisconnectWebSocket);
    on<SendMessageRequested>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
  }

  Future<void> _onLoadRooms(LoadRoomsRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final rooms = await _dataSource.getRooms();
      emit(ChatRoomsLoaded(rooms));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> _onCreateRoom(CreateRoomRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final room = await _dataSource.getOrCreateRoom(event.productId, event.sellerId);
      emit(ChatRoomCreated(room));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessagesRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      _currentMessages = await _dataSource.getRoomMessages(event.roomId);
      emit(ChatMessagesLoaded(List.from(_currentMessages)));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> _onConnectWebSocket(ConnectWebSocketRequested event, Emitter<ChatState> emit) async {
    try {
      _channel = await _dataSource.connectToChatWebSocketWithToken();
      _wsSubscription = _channel!.stream.listen(
        (data) {
          final messageJson = jsonDecode(data);
          final message = ChatMessage.fromJson(messageJson);
          add(MessageReceived(message));
        },
        onError: (error) {
          add(DisconnectWebSocketRequested());
        },
        onDone: () {
          add(DisconnectWebSocketRequested());
        },
      );
    } catch (e) {
      // Handle connection error silently or emit failure
    }
  }

  void _onDisconnectWebSocket(DisconnectWebSocketRequested event, Emitter<ChatState> emit) {
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _onSendMessage(SendMessageRequested event, Emitter<ChatState> emit) {
    if (_channel != null) {
      final messageData = {
        'room_id': event.roomId,
        'text': event.text,
      };
      _channel!.sink.add(jsonEncode(messageData));
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    if (state is ChatMessagesLoaded) {
      _currentMessages.add(event.message);
      emit(ChatMessagesLoaded(List.from(_currentMessages)));
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _channel?.sink.close();
    return super.close();
  }
}
