import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required String id,
    required String senderId,
    required String text,
    required DateTime timestamp,
    required bool read,
  }) : super(
          id: id,
          senderId: senderId,
          text: text,
          timestamp: timestamp,
          read: read,
        );

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};

  // 1. Gelişmiş Timestamp Kontrolü
  dynamic timestamp = data['timestamp'];
  DateTime messageTime;

  if (timestamp is Timestamp) {
    messageTime = timestamp.toDate();
  } 
  else if (timestamp is DateTime) {
    messageTime = timestamp;
  }
  else if (timestamp == null) {
    // 2. Firestore'dan yeni gelen mesajlarda oluşan geçici null durumu
    messageTime = DateTime.now();
    print('⚠️ Geçici timestamp hatası: ${doc.id} - Otomatik düzeltildi');
  }
  else {
    // 3. Beklenmeyen veri tipi
    messageTime = DateTime.now();
    print('⚠️ Geçersiz timestamp tipi: ${timestamp.runtimeType}');
  }

  return MessageModel(
    id: doc.id,
    text: data['text']?.toString() ?? '',
    senderId: data['senderId']?.toString() ?? '',
    timestamp: messageTime,
    read: data['read'] as bool? ?? false,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
    };
  }
}