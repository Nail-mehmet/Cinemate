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
    try {
      final response = await supabaseClient
          .from(SupabaseConstants.participantsTable)
          .select('user_id')
          .eq('chat_id', chatId)
          .neq('user_id', currentUserId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Diğer katılımcı bulunamadı');
      }

      final otherUserId = response['user_id'] as String;

      final profile = await supabaseClient
          .from(SupabaseConstants.profilesTable)
          .select('id, name, profile_image')
          .eq('id', otherUserId)
          .single();

      return profile;
    } catch (e) {
      print('getOtherParticipantProfile error: $e');
      rethrow;
    }
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

  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    final response = await supabaseClient
        .from(SupabaseConstants.messagesTable)
        .select()
        .eq('chat_id', chatId)
        .neq('sender_id', userId)
        .eq('is_read', false);

    return (response as List).length;
  }


  // Kullanıcının tüm chatlerini getir
  // ChatRepository.dart
  Future<List<Chat>> getUserChats(String userId) async {
    final response = await supabaseClient
        .from(SupabaseConstants.participantsTable)
        .select('''
        chat_id, 
        chats (
          id, 
          created_at, 
          last_message, 
          last_message_time, 
          last_message_sender
        )
      ''')
        .eq('user_id', userId);

    final chats = <Chat>[];

    for (final record in response) {
      final chatMap = record['chats'];
      if (chatMap != null) {
        chats.add(Chat.fromMap(chatMap));
      }
    }

    // Son mesaj zamanına göre TERSINE sırala (en yeni en üstte)
    chats.sort((a, b) {
      final aTime = a.lastMessageTime ?? DateTime(1970);
      final bTime = b.lastMessageTime ?? DateTime(1970);
      return bTime.compareTo(aTime); // Tersine sıralama için bTime ile aTime'ın yerini değiştiriyoruz
    });

    return chats;
  }

  // ChatRepository.dart'e ekle
  Stream<int> watchUnreadMessageCount(String chatId, String userId) {
    return supabaseClient
        .from(SupabaseConstants.messagesTable)
        .select()
        .eq('chat_id', chatId)
        .eq('is_read', false)
        .filter('sender_id', 'neq', userId)
        .asStream()
        .map((event) => event.length);
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
    final message = await supabaseClient
        .from(SupabaseConstants.messagesTable)
        .insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    })
        .select()
        .single();

    // Chat'in son mesaj bilgilerini güncelle (diğer kullanıcının chat listesini güncellemek için)
    await supabaseClient
        .from(SupabaseConstants.chatsTable)
        .update({
      'last_message': content,
      'last_message_time': DateTime.now().toIso8601String(),
      'last_message_sender': senderId,
    })
        .eq('id', chatId);

    return Message.fromMap(message);
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