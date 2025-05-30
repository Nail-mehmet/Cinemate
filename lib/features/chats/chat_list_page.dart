import 'package:Cinemate/features/chats/chat_bloc.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  final String userId;

  const ChatListPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: ChatRepository(supabaseClient: Supabase.instance.client))..add(LoadChats(userId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mesajlar')),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state.status == ChatStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == ChatStatus.failure) {
              return Center(child: Text('Hata: ${state.error}'));
            }

            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return ListTile(
                  title: Text(chat.lastMessage ?? 'Yeni sohbet'),
                  subtitle: Text(
                    chat.lastMessageTime != null
                        ? '${chat.lastMessageTime!.hour}:${chat.lastMessageTime!.minute}'
                        : '',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatId: chat.id,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}