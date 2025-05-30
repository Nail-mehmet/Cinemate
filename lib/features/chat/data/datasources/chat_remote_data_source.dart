/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Cinemate/features/chat/data/models/chat_model.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../models/message_model.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı bilgilerini çeken yardımcı metod
  Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return {'name': 'User', 'profileImageUrl': ''};
      
      final data = doc.data()!;
      return {
        'name': data['name']?.toString().trim() ?? 'User',
        'profileImageUrl': data['profileImageUrl']?.toString().trim() ?? '',
      };
    } catch (e) {
      print('Error fetching user profile: $e');
      return {'name': 'User', 'profileImageUrl': ''};
    }
  }

  // İyileştirilmiş chat başlatma metodu
  Future<String> startChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      // Var olan sohbet kontrolü
      final existingChat = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (final doc in existingChat.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Kullanıcı profillerini paralel çek
      final futures = await Future.wait([
        _getUserProfile(currentUserId),
        _getUserProfile(otherUserId),
      ]);

      final currentUser = futures[0];
      final otherUser = futures[1];

      // Yeni sohbet oluştur
      final chatRef = _firestore.collection('chats').doc();
      
      await chatRef.set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': '',
        'createdAt': FieldValue.serverTimestamp(),
        'participantData': {
          currentUserId: {
            'name': currentUser['name'],
            'avatar': currentUser['profileImageUrl'],
            'uid': currentUserId,
          },
          otherUserId: {
            'name': otherUser['name'],
            'avatar': otherUser['profileImageUrl'],
            'uid': otherUserId,
          },
        },
      });

      return chatRef.id;
    } catch (e) {
      print('Error starting chat: $e');
      throw Exception('Sohbet başlatılamadı');
    }
  }

  // Diğer metodlar aynı kalabilir...
  Stream<List<ChatEntity>> getChats(String userId) {
  // 1. Index hatasını bypass etmek için sadece where kullanın
  return _firestore
      .collection('chats')
      .where('participants', arrayContains: userId)
      .snapshots()
      .map((snapshot) {
        // 2. Client tarafında sıralama yapın
        final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
          
        chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        return chats;
      });
}

  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage({
  required String chatId,
  required String senderId,
  required String text,
}) async {
  final batch = _firestore.batch();
  final messageRef = _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc();

  // Karşı tarafı belirle
  final chatDoc = await _firestore.collection('chats').doc(chatId).get();
  final participants = List<String>.from(chatDoc['participants']);
  final receiverId = participants.firstWhere((id) => id != senderId);

  final chatRef = _firestore.collection('chats').doc(chatId);

  // Mesaj oluştur
  batch.set(messageRef, {
    'senderId': senderId,
    'text': text,
    'timestamp': FieldValue.serverTimestamp(),
    'read': false,
  });

  // Son mesaj bilgisi güncelle
  batch.update(chatRef, {
    'lastMessage': text,
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastMessageSender': senderId,
  });

  // unreadMessageCounts güncelle
  final chatSnap = await chatRef.get();
  final data = chatSnap.data();
  Map<String, dynamic> unread = {};
  if (data != null && data.containsKey('unreadCounts')) {
    unread = Map<String, dynamic>.from(data['unreadCounts']);
  }

  final currentUnread = unread[receiverId] ?? 0;
  unread[receiverId] = currentUnread + 1;

  batch.update(chatRef, {'unreadCounts': unread});

  await batch.commit();
}



  @override
Future<void> markMessageAsRead({
  required String chatId,
  required String messageId,
}) async {
  final messageRef = _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(messageId);

  final messageSnap = await messageRef.get();
  if (messageSnap.exists && messageSnap.data()?['read'] == false) {
    await messageRef.update({'read': true});

    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageData = messageSnap.data();
    final senderId = messageData?['senderId'];

    // Şu anki kullanıcı kim?
    final chatSnap = await chatRef.get();
    final participants = List<String>.from(chatSnap['participants']);
    final readerId = participants.firstWhere((id) => id != senderId);

    await _firestore.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatRef);
      final data = chatDoc.data();

      if (data != null && data.containsKey('unreadCounts')) {
        final unread = Map<String, dynamic>.from(data['unreadCounts']);
        if (unread.containsKey(readerId)) {
          unread[readerId] = 0;
          transaction.update(chatRef, {'unreadCounts': unread});
        }
      }
    });
  }
}

Future<void> resetUnreadCount({
  required String chatId,
  required String userId,
}) async {
  final chatRef = _firestore.collection('chats').doc(chatId);

  await _firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(chatRef);
    final data = snapshot.data();
    if (data != null && data.containsKey('unreadCounts')) {
      final unread = Map<String, dynamic>.from(data['unreadCounts']);
      unread[userId] = 0;
      transaction.update(chatRef, {'unreadCounts': unread});
    }
  });
}


}z*/