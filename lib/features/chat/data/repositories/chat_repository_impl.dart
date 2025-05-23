/*import 'package:flutter/foundation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatEntity>> getChats(String userId) {
    try {
      if (userId.isEmpty) throw ArgumentError('Invalid user ID');
      
      return remoteDataSource.getChats(userId).handleError((error, stackTrace) {
        debugPrint('Chat stream error: $error\n$stackTrace');
        throw Exception('Failed to load chats. Please try again.');
      });
    } catch (e, stackTrace) {
      debugPrint('Get chats error: $e\n$stackTrace');
      throw Exception('Failed to load chats. Please check your connection.');
    }
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    try {
      if (chatId.isEmpty) throw ArgumentError('Invalid chat ID');
      
      return remoteDataSource.getMessages(chatId).handleError((error, stackTrace) {
        debugPrint('Message stream error: $error\n$stackTrace');
        throw Exception('Failed to load messages. Please try again.');
      });
    } catch (e, stackTrace) {
      debugPrint('Get messages error: $e\n$stackTrace');
      throw Exception('Failed to load messages. Please check your connection.');
    }
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      if (chatId.isEmpty || senderId.isEmpty || text.trim().isEmpty) {
        throw ArgumentError('Invalid message data');
      }

      await remoteDataSource.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: text.trim(),
      );
    } catch (e, stackTrace) {
      debugPrint('Send message error: $e\n$stackTrace');
      throw Exception('Failed to send message. Please try again.');
    }
  }

  @override
  Future<String> startChat({
    required String currentUserId,
    required String otherUserId,
    String? currentUserName,
    String? currentUserAvatar,
    String? otherUserName,
    String? otherUserAvatar,
  }) async {
    try {
      if (currentUserId.isEmpty || otherUserId.isEmpty) {
        throw ArgumentError('Invalid user IDs');
      }

      return await remoteDataSource.startChat(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      );
    } catch (e, stackTrace) {
      debugPrint('Start chat error: $e\n$stackTrace');
      throw Exception('Failed to start chat. Please try again.');
    }
  }

  @override
  @override
Future<void> markMessageAsRead({required String chatId, required String messageId}) async {
  try {
    if (chatId.isEmpty || messageId.isEmpty) {
      throw ArgumentError('Invalid message data');
    }

    await remoteDataSource.markMessageAsRead(chatId: chatId, messageId: messageId);
  } catch (e, stackTrace) {
    debugPrint('Mark as read error: $e\n$stackTrace');
    throw Exception('Failed to update read status. Please try again.');
  }
}

    
}*/