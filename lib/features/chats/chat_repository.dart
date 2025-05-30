import 'package:Cinemate/features/chats/chat_model.dart';
import 'package:Cinemate/features/chats/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';

class ChatRepository {
  final SupabaseClient supabaseClient;

  ChatRepository({required this.supabaseClient});


  // Yeni metodlar ekleyelim
  Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await supabaseClient
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  Future<Map<String, dynamic>> getOtherParticipantProfile(
      String chatId,
      String currentUserId,
      ) async {
    final response = await supabaseClient
        .from(SupabaseConstants.participantsTable)
        .select('profiles:user_id (id, username, avatar_url)')
        .eq('chat_id', chatId)
        .neq('user_id', currentUserId)
        .single();
    return response['profiles'];
  }

  // Yeni chat oluştur
  Future<Chat> createChat(String currentUserId, String otherUserId) async {
    // Önce chat oluştur
    final chatResponse = await supabaseClient
        .from(SupabaseConstants.chatsTable)
        .insert({})
        .select()
        .single();

    final chat = Chat.fromMap(chatResponse);

    // Katılımcıları ekle
    await supabaseClient.from(SupabaseConstants.participantsTable).insert([
      {'chat_id': chat.id, 'user_id': currentUserId},
      {'chat_id': chat.id, 'user_id': otherUserId},
    ]);

    return chat;
  }

  // Kullanıcının tüm chatlerini getir
  Future<List<Chat>> getUserChats(String userId) async {
    final response = await supabaseClient
        .from(SupabaseConstants.participantsTable)
        .select('''
          chat_id, 
          chats:chat_id (id, created_at, last_message, last_message_time, last_message_sender)
        ''')
        .eq('user_id', userId);

    return (response as List)
        .map((e) => Chat.fromMap(e['chats']))
        .toList();
  }

  // Belirli bir chat'in mesajlarını getir
  Future<List<Message>> getChatMessages(String chatId) async {
    final response = await supabaseClient
        .from(SupabaseConstants.messagesTable)
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return (response as List).map((e) => Message.fromMap(e)).toList();
  }

  // Mesaj gönder
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    // Mesajı ekle
    final messageResponse = await supabaseClient
        .from(SupabaseConstants.messagesTable)
        .insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    })
        .select()
        .single();

    // Chat'in son mesajını güncelle
    await supabaseClient
        .from(SupabaseConstants.chatsTable)
        .update({
      'last_message': content,
      'last_message_time': DateTime.now().toIso8601String(),
      'last_message_sender': senderId,
    })
        .eq('id', chatId);

    return Message.fromMap(messageResponse);
  }

  // Mesajları okundu olarak işaretle
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await supabaseClient
        .from(SupabaseConstants.messagesTable)
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .neq('sender_id', userId);
  }

  // İki kullanıcı arasındaki chat'i bul
  Future<Chat?> findChatBetweenUsers(String user1Id, String user2Id) async {
    final response = await supabaseClient
        .from(SupabaseConstants.participantsTable)
        .select('chat_id, user_id, chats:chat_id (id, created_at, last_message, last_message_time, last_message_sender)')
        .inFilter('user_id', [user1Id, user2Id]);

    if (response == null || response.isEmpty) return null;

    // chat_id’leri grupla
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final row in response) {
      final chatId = row['chat_id'] as String;
      grouped.putIfAbsent(chatId, () => []).add(row);
    }

    // İki kullanıcıyı içeren chat’i bul
    for (final entry in grouped.entries) {
      final participants = entry.value.map((e) => e['user_id']).toSet();
      if (participants.contains(user1Id) && participants.contains(user2Id) && participants.length == 2) {
        return Chat.fromMap(entry.value.first['chats']);
      }
    }

    return null;
  }

}