import 'dart:async';
import 'package:Cinemate/core/constants/supabase_constants.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:Cinemate/features/chats/message_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<Message>>? _messagesSubscription;

  MessageBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const MessageState()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<MessagesUpdated>(_onMessagesUpdated);

  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<MessageState> emit) {
    emit(state.copyWith(messages: event.messages));
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) async {
    emit(state.copyWith(status: MessageStatus.loading));

    try {
      // Önceki aboneliği iptal et
      _messagesSubscription?.cancel();

      // İlk mesajları yükle
      final initialMessages = await _chatRepository.getChatMessages(event.chatId);
      emit(state.copyWith(status: MessageStatus.success, messages: initialMessages));

      // Realtime dinleyiciyi başlat
      _messagesSubscription = _chatRepository.supabaseClient
          .from(SupabaseConstants.messagesTable)
          .stream(primaryKey: ['id'])
          .eq('chat_id', event.chatId)
          .order('created_at', ascending: true)
          .map((messages) => messages.map((m) => Message.fromMap(m)).toList())
          .listen((messages) {
        // Yeni mesajlar geldiğinde state'i güncelle
        add(MessagesUpdated(messages)); // Yeni bir event ekleyelim
      });

    } catch (e) {
      emit(state.copyWith(status: MessageStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MessageState> emit) async {
    try {
      await _chatRepository.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        content: event.content,
      );
      // Manuel ekleme YAPMIYORUZ, Realtime'dan gelecek
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }


  Future<void> _onMarkMessagesAsRead(MarkMessagesAsRead event, Emitter<MessageState> emit) async {
    try {
      await _chatRepository.markMessagesAsRead(event.chatId, event.userId);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}