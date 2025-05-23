import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    required String id,
    required List<String> participants,
    required String lastMessage,
    required DateTime lastMessageTime,
    required String lastMessageSender,
    required Map<String, ParticipantData> participantData,
    Map<String, int> unreadCounts = const {},
    Map<String, bool> isTyping = const {}, // ✅ EKLENDİ
  }) : super(
          id: id,
          participants: participants,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          lastMessageSender: lastMessageSender,
          participantData: participantData,
          unreadCounts: unreadCounts,
          isTyping: isTyping, // ✅ EKLENDİ
        );

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants']),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSender: data['lastMessageSender'] ?? '',
      participantData: (data['participantData'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          ParticipantData(
            name: value['name'],
            avatar: value['avatar'],
          ),
        ),
      ),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      isTyping: Map<String, bool>.from(data['isTyping'] ?? {}), // ✅ EKLENDİ
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSender': lastMessageSender,
      'participantData': participantData.map(
        (key, value) => MapEntry(
          key,
          {
            'name': value.name,
            'avatar': value.avatar,
          },
        ),
      ),
      'unreadCounts': unreadCounts,
      'isTyping': isTyping, // ✅ EKLENDİ
    };
  }
}