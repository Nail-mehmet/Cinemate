class Participant {
  final String chatId;
  final String userId;
  final DateTime joinedAt;

  Participant({
    required this.chatId,
    required this.userId,
    required this.joinedAt,
  });

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      chatId: map['chat_id'] as String,
      userId: map['user_id'] as String,
      joinedAt: DateTime.parse(map['joined_at'] as String),
    );
  }
}