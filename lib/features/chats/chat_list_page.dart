import 'package:Cinemate/features/chats/chat_bloc.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  final String userId;

  const ChatListPage({super.key, required this.userId});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatRepository chatRepository;
  late ChatBloc chatBloc;

  @override
  void initState() {
    super.initState();
    chatRepository = ChatRepository(supabaseClient: Supabase.instance.client);
    chatBloc = ChatBloc(chatRepository: chatRepository);
    chatBloc.add(LoadChats(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: chatBloc,
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
                return FutureBuilder<Map<String, dynamic>>(
                  future: chatRepository.getOtherParticipantProfile(chat.id, widget.userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        title: Text('Yükleniyor...'),
                      );
                    }

                    final profile = snapshot.data!;
                    return ListTile(
                      title: Text(profile['name'] ?? 'Kullanıcı'),
                      leading: CircleAvatar(
                        backgroundImage: profile['profile_image'] != null
                            ? NetworkImage(profile['profile_image'])
                            : null,
                        child: profile['profile_image'] == null ? const Icon(Icons.person) : null,
                      ),

                      subtitle: Text(
                        chat.lastMessage ?? 'Yeni sohbet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '${chat.lastMessageTime.hour.toString().padLeft(2, '0')}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatId: chat.id,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
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
