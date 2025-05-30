/*import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:Cinemate/features/chat/domain/entities/chat_entity.dart';
import 'package:Cinemate/features/chat/domain/entities/message_entity.dart';
import 'package:Cinemate/features/chat/domain/usecases/get_chats.dart';
import 'package:Cinemate/features/chat/domain/usecases/send_messages.dart';
import 'package:Cinemate/features/chat/domain/usecases/start_chat.dart';
import 'package:Cinemate/features/chat/domain/usecases/get_messages.dart';
import 'package:Cinemate/features/chat/domain/usecases/mark_message_as_read.dart'; // ✅ bunu ekle

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetChats getChats;
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final StartChat startChat;
  final MarkMessageAsRead markMessageAsRead; // ✅ bunu ekle

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  List<MessageEntity> _currentMessages = [];

  ChatCubit({
    required this.getChats,
    required this.getMessages,
    required this.sendMessage,
    required this.startChat,
    required this.markMessageAsRead, // ✅ bunu ekle
  }) : super(ChatInitial());

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  void fetchChats(String userId) {
    emit(ChatLoading());
    try {
      getChats(userId).listen((chats) {
        emit(ChatsLoaded(chats));
      }, onError: (error) {
        emit(ChatsLoaded([]));
      });
    } catch (e) {
      emit(ChatsLoaded([]));
    }
  }

  void fetchMessages(String chatId, {bool silent = false}) {
    if (!silent) emit(ChatLoading());

    _messagesSubscription?.cancel();

    _messagesSubscription = getMessages(chatId).listen(
      (messages) {
        _currentMessages = messages;
        emit(MessagesLoaded(messages));
      },
      onError: (error) {
        emit(MessagesLoaded(_currentMessages));
      },
    );
  }

  Future<void> sendNewMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      final newMessage = MessageEntity(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        senderId: senderId,
        timestamp: DateTime.now(),
        read: false,
      );

      _currentMessages = [..._currentMessages, newMessage];
      emit(MessagesLoaded(_currentMessages));

      await sendMessage.call(
        chatId: chatId,
        senderId: senderId,
        text: text,
      );

      fetchMessages(chatId, silent: true);
    } catch (e) {
      _currentMessages = _currentMessages.where((m) => !m.id.startsWith('temp-')).toList();
      emit(MessagesLoaded(_currentMessages));
    }
  }

  void clearMessages() {
    _currentMessages = [];
    emit(ChatInitial());
  }

  Future<void> startNewChat({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String currentUserAvatar,
    required String otherUserName,
    required String otherUserAvatar,
  }) async {
    try {
      emit(ChatLoading());
      final chatId = await startChat.call(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
      );
      emit(ChatStarted(chatId));
    } catch (e) {
      emit(ChatError('Sohbet başlatılamadı'));
    }
  }

  // ✅ Yeni eklenen fonksiyon
  Future<void> markMessageAsread(String chatId, String messageId) async {
    try {
      await markMessageAsRead.call(chatId: chatId, messageId: messageId);
    } catch (e) {
      // Hata loglanabilir
    }
  }

  void _updateUnreadMessagesCount(String chatId) {
  final List<ChatEntity> updatedChats = state is ChatsLoaded
    ? (state as ChatsLoaded).chats.map((chat) {
        if (chat.id == chatId) {
          final unreadCount = _currentMessages.where((msg) => !msg.read).length;
          return chat.copyWith(unreadMessagesCount: unreadCount);
        }
        return chat;
      }).toList()
    : [];


  emit(ChatsLoaded(updatedChats));
}

}
*/