class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.delivered,
  });

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus { sending, delivered, error }

class ChatHistory {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;

  const ChatHistory({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
  });
}
