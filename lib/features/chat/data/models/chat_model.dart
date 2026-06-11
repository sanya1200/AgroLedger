class ChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      text: json['text'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'text': text,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ChatRoom {
  final int id;
  final int productId;
  final int buyerId;
  final int sellerId;
  final DateTime createdAt;
  final List<ChatMessage> messages;
  final dynamic buyer;
  final dynamic seller;

  ChatRoom({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    this.messages = const [],
    this.buyer,
    this.seller,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      productId: json['product_id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      messages: (json['messages'] as List?)
              ?.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      buyer: json['buyer'],
      seller: json['seller'],
    );
  }
}
