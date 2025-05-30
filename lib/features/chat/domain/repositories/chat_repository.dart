/*import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  // Kullanıcının tüm sohbetlerini getirir
  Stream<List<ChatEntity>> getChats(String userId);
  
  // Belirli bir sohbetteki mesajları getirir
  Stream<List<MessageEntity>> getMessages(String chatId);
  
  // Yeni mesaj gönderir
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });
  
  // Yeni sohbet başlatır
  Future<String> startChat({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String currentUserAvatar,
    required String otherUserName,
    required String otherUserAvatar,
  });
  
  // Mesajı okundu olarak işaretler
  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  });
}*/