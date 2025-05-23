/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/chat/domain/entities/chat_entity.dart';
import 'package:Cinemate/features/chat/presentation/components/noti_icon_badge.dart';
import 'package:Cinemate/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:Cinemate/features/chat/presentation/pages/chat_page.dart';
import 'package:Cinemate/features/notifications/presentation/pages/notifications_page.dart';
import 'package:Cinemate/themes/font_theme.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  late final String _userId;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthCubit>().currentUser;
    _userId = currentUser?.uid ?? '';

    if (_userId.isNotEmpty) {
      _loadChatsWithRetry();
    }
  }

  Future<void> _loadChatsWithRetry() async {
    try {
      // Chat sayfasından dönerken mesajları temizle
      context.read<ChatCubit>().clearMessages();
      context.read<ChatCubit>().fetchChats(_userId);
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.read<ChatCubit>().fetchChats(_userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlar'), actions: [
        NotificationIconWithBadge(currentUserId: _userId),
      ]),
      body: _userId.isEmpty
          ? const Center(child: Text('Kullanıcı girişi gerekli'))
          : BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatsLoaded) {
                  return _buildChatList(state.chats);
                } else if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hata: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadChatsWithRetry,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }

  Widget _buildChatList(List<ChatEntity> chats) {
    if (chats.isEmpty) {
      return const Center(child: Text('Henüz mesajınız yok'));
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final otherParticipant = chat.participants.firstWhere(
          (id) => id != _userId,
          orElse: () => '',
        );

        final participantData = otherParticipant.isNotEmpty
            ? chat.participantData[otherParticipant]
            : null;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: participantData?.avatar.isNotEmpty == true
                ? NetworkImage(participantData!.avatar)
                : null,
            child: participantData?.avatar.isEmpty != false
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(participantData?.name ?? 'Bilinmeyen Kullanıcı',style: AppTextStyles.medium,),
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.regular,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(chat.lastMessageTime),
                style: AppTextStyles.bold
              ),
              const SizedBox(height: 4),
              if ((chat.unreadCounts[_userId] ?? 0) > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${chat.unreadCounts[_userId]}',
                    style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          // ChatsListPage içinde _buildChatList metodunda:
          onTap: () {
            if (chat.id.isNotEmpty) {
              context.read<ChatCubit>().clearMessages();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatId: chat.id,
                    otherUserName: participantData!.name,
                    otherUserId: otherParticipant, // Yeni eklenen parametre
                    otherUserAvatar:
                        participantData.avatar, // Yeni eklenen parametre
                  ),
                ),
              ).then((_) {
                _loadChatsWithRetry();
              });
            }
          },
        );
      },
    );
  }

  String _formatTime(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final thisWeek = today.subtract(const Duration(days: 6)); // 6 gün önceye kadar
  
  final timeDate = DateTime(time.year, time.month, time.day);
  
  if (timeDate == today) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  } else if (timeDate == yesterday) {
    return 'Dün';
  } else if (timeDate.isAfter(thisWeek)) {
    // Haftanın gün ismini Türkçe olarak döndür
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return days[time.weekday - 1];
  } else {
    // 1 haftadan eski ise tarihi göster (örnek: 20.05.2023)
    return '${time.day}.${time.month}.${time.year}';
  }
}
}
*/