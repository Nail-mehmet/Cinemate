/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Cinemate/features/chat/domain/entities/message_entity.dart';
import 'package:Cinemate/features/chat/domain/repositories/chat_repository.dart';

class FirebaseChatRepo implements ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirebaseChatRepo()
      : firestore = FirebaseFirestore.instance,
        auth = FirebaseAuth.instance;

  @override
  Future<String> createChat(String currentUserId, String otherUserId) async {
  try {
    // 1. Null kontrolü ekleyin
    if (currentUserId.isEmpty || otherUserId.isEmpty) {
      throw Exception('Geçersiz kullanıcı ID');
    }

    // 2. Firestore doküman referansı
    final chatRef = firestore.collection('chats').doc();
    
    // 3. Garantili timestamp oluşturma
    final serverTimestamp = FieldValue.serverTimestamp();
    final initialData = {
      'participants': [currentUserId, otherUserId],
      'lastMessage': '',
      'lastMessageSender': '',
      'lastMessageTime': serverTimestamp, // Direkt FieldValue
      'createdAt': serverTimestamp, // Direkt FieldValue
      'participantData': {
        currentUserId: {
          'name': (await _getUserData(currentUserId))['name'] ?? 'İsimsiz',
          'avatar': (await _getUserData(currentUserId))['profileImageUrl'] ?? '',
          'uid': currentUserId,
        },
        otherUserId: {
          'name': (await _getUserData(otherUserId))['name'] ?? 'İsimsiz',
          'avatar': (await _getUserData(otherUserId))['profileImageUrl'] ?? '',
          'uid': otherUserId,
        },
      },
    };

    // 4. Transaction içinde yazma işlemi
    await firestore.runTransaction((transaction) async {
      transaction.set(chatRef, initialData);
    });

    return chatRef.id;
  } catch (e, stack) {
    print('Chat oluşturma hatası: $e\n$stack');
    throw Exception('Sohbet oluşturulamadı. Lütfen tekrar deneyin.');
  }
}

// Güçlendirilmiş _getUserData metodu
Future<Map<String, dynamic>> _getUserData(String userId) async {
  try {
    if (userId.isEmpty) return {'name': 'İsimsiz', 'profileImageUrl': ''};
    
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) return {'name': 'İsimsiz', 'profileImageUrl': ''};

    final data = doc.data() ?? {};
    return {
      'name': data['name']?.toString().trim() ?? 'İsimsiz',
      'profileImageUrl': data['profileImageUrl']?.toString().trim() ?? '',
    };
  } catch (e) {
    //debugPrint('Kullanıcı verisi çekme hatası: $e');
    return {'name': 'İsimsiz', 'profileImageUrl': ''};
  }
}

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MessageEntity(
                id: doc.id,
                text: data['text']?.toString() ?? '',
                senderId: data['senderId']?.toString() ?? '',
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                read: data['read'] as bool? ?? false,
              );
            }).toList());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}*/