import 'package:equatable/equatable.dart';
import 'package:agroledger/features/chat/data/models/chat_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> rooms;

  const ChatRoomsLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class ChatRoomCreated extends ChatState {
  final ChatRoom room;

  const ChatRoomCreated(this.room);

  @override
  List<Object?> get props => [room];
}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatFailure extends ChatState {
  final String message;

  const ChatFailure(this.message);

  @override
  List<Object?> get props => [message];
}
