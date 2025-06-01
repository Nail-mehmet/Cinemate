import 'dart:async';
import 'package:Cinemate/core/constants/supabase_constants.dart';
import 'package:Cinemate/features/chats/chat_model.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<Map<String, dynamic>>>? _chatsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;


  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatState()) {
    on<LoadChats>(_onLoadChats);
    on<CreateChat>(_onCreateChat);
    on<UpdateChats>(_onUpdateChats);
  }

  // ChatBloc.dart
  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      // İlk verileri yükle
      final chats = await _chatRepository.getUserChats(event.userId);
      emit(state.copyWith(status: ChatStatus.success, chats: chats));

      // Chat listesi için realtime aboneliği
      _chatsSubscription?.cancel();
      _chatsSubscription = _chatRepository.supabaseClient
          .from(SupabaseConstants.chatsTable)
          .stream(primaryKey: ['id'])
          .listen((_) async {
        final updatedChats = await _chatRepository.getUserChats(event.userId);
        add(UpdateChats(updatedChats));
      });

      // Mesajlar için realtime aboneliği (son mesajın güncellenmesi için)
      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.supabaseClient
          .from(SupabaseConstants.messagesTable)
          .stream(primaryKey: ['id'])
          .listen((_) async {
        final updatedChats = await _chatRepository.getUserChats(event.userId);
        add(UpdateChats(updatedChats));
      });

    } on PostgrestException catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, error: e.message));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      // Önce var olan bir chat olup olmadığını kontrol et
      final existingChat = await _chatRepository.findChatBetweenUsers(
        event.currentUserId,
        event.otherUserId,
      );

      if (existingChat != null) {
        emit(state.copyWith(status: ChatStatus.success));
        return;
      }

      // Yeni chat oluştur
      await _chatRepository.createChat(event.currentUserId, event.otherUserId);
      emit(state.copyWith(status: ChatStatus.success));
    } on PostgrestException catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, error: e.message));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, error: e.toString()));
    }
  }

  void _onUpdateChats(UpdateChats event, Emitter<ChatState> emit) {
    emit(state.copyWith(chats: event.chats));
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}