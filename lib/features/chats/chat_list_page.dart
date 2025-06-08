import 'package:Cinemate/features/chats/chat_bloc.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';
import 'noti_icon_badge.dart';

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
  // ChatListPage.dart
  // ChatListPage.dart
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: chatBloc,
      child: Scaffold(
        appBar: AppBar(title: Text('Mesajlar',style: AppTextStyles.bold,), actions: [
          NotificationIconWithBadge(currentUserId: widget.userId),
        ]),
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
                  builder: (context, profileSnapshot) {
                    if (!profileSnapshot.hasData) {
                      return const ListTile(title: Text('Yükleniyor...'));
                    }

                    final profile = profileSnapshot.data!;

                    return StreamBuilder<int>(
                      stream: chatRepository.watchUnreadMessageCount(chat.id, widget.userId),
                      builder: (context, unreadSnapshot) {
                        final unreadCount = unreadSnapshot.data ?? 0;

                        return ListTile(
                          title: Text(profile['name'] ?? 'Kullanıcı',style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),),
                          leading: CircleAvatar(
                            backgroundImage: profile['profile_image'] != null
                                ? NetworkImage(profile['profile_image'])
                                : null,
                            child: profile['profile_image'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          subtitle: Text(
                            chat.lastMessage ?? 'Yeni sohbet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatMessageTime(chat.lastMessageTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: unreadCount > 0
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
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
            );
          },
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Dün';
    } else if (now.difference(messageDate).inDays < 7) {
      switch (dateTime.weekday) {
        case 1: return 'Pazartesi';
        case 2: return 'Salı';
        case 3: return 'Çarşamba';
        case 4: return 'Perşembe';
        case 5: return 'Cuma';
        case 6: return 'Cumartesi';
        case 7: return 'Pazar';
        default: return '';
      }
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
