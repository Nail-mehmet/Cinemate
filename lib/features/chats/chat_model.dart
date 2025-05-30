class Chat {
  final String id;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;

  Chat({
    required this.id,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastMessage: map['last_message'] as String?,
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'] as String)
          : null,
      lastMessageSender: map['last_message_sender'] as String?,
    );
  }
}