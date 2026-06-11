import 'package:equatable/equatable.dart';
import 'package:agroledger/features/chat/data/models/chat_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoomsRequested extends ChatEvent {}

class CreateRoomRequested extends ChatEvent {
  final int productId;
  final int sellerId;

  const CreateRoomRequested(this.productId, this.sellerId);

  @override
  List<Object?> get props => [productId, sellerId];
}

class LoadMessagesRequested extends ChatEvent {
  final int roomId;

  const LoadMessagesRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class ConnectWebSocketRequested extends ChatEvent {}

class DisconnectWebSocketRequested extends ChatEvent {}

class SendMessageRequested extends ChatEvent {
  final int roomId;
  final String text;

  const SendMessageRequested(this.roomId, this.text);

  @override
  List<Object?> get props => [roomId, text];
}

class MessageReceived extends ChatEvent {
  final ChatMessage message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
