/*class ChatEntity {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSender;
  final Map<String, ParticipantData> participantData;
  final int unreadMessagesCount;
  final Map<String, int> unreadCounts;
  final Map<String, bool> isTyping; // ✅ EKLENDİ

  ChatEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSender,
    required this.participantData,
    this.unreadMessagesCount = 0,
    this.unreadCounts = const {},
    this.isTyping = const {}, // ✅ EKLENDİ
  });

  ChatEntity copyWith({
    String? id,
    List<String>? participants,
    Map<String, ParticipantData>? participantData,
    String? lastMessage,
    String? lastMessageSender,
    DateTime? lastMessageTime,
    int? unreadMessagesCount,
    Map<String, int>? unreadCounts,
    Map<String, bool>? isTyping, // ✅ EKLENDİ
  }) {
    return ChatEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantData: participantData ?? this.participantData,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      isTyping: isTyping ?? this.isTyping, // ✅ EKLENDİ
    );
  }
}

class ParticipantData {
  final String name;
  final String avatar;

  ParticipantData({
    required this.name,
    required this.avatar,
  });
}*/