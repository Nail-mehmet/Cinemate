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
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  MessageBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const MessageState()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) async {
    emit(state.copyWith(status: MessageStatus.loading));

    try {
      // Realtime aboneliği başlat
      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.supabaseClient
          .from('${SupabaseConstants.messagesTable}:chat_id=eq.${event.chatId}')
          .stream(primaryKey: ['id'])
          .listen((data) {
        final messages = data.map((e) => Message.fromMap(e)).toList();
        add(LoadMessages(event.chatId)); // Yeniden yükleme tetikler
      });

      // İlk verileri yükle
      final messages = await _chatRepository.getChatMessages(event.chatId);
      emit(state.copyWith(status: MessageStatus.success, messages: messages));
    } on PostgrestException catch (e) {
      emit(state.copyWith(status: MessageStatus.failure, error: e.message));
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
    } on PostgrestException catch (e) {
      emit(state.copyWith(error: e.message));
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