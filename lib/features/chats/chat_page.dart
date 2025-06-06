import 'package:Cinemate/features/chats/chat_bubble.dart';
import 'package:Cinemate/features/chats/chat_input.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:Cinemate/features/chats/message_bloc.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String userId;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.userId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();
  late Future<Map<String, dynamic>> _otherUserFuture;
  bool _isAtBottom = true;
  bool _isFirstLoad = true;


  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(LoadMessages(widget.chatId));

    _markMessagesAsRead();

    _scrollController.addListener(_scrollListener);
    _otherUserFuture = ChatRepository(
      supabaseClient: Supabase.instance.client,
    ).getOtherParticipantProfile(widget.chatId, widget.userId);
  }

  void _scrollListener() {
    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50;

    if (isAtBottom != _isAtBottom) {
      setState(() => _isAtBottom = isAtBottom);
      if (isAtBottom) {
        _markMessagesAsRead();
      }
    }
  }
  void _markMessagesAsRead() {
    context.read<MessageBloc>().add(MarkMessagesAsRead(widget.chatId, widget.userId));
  }

  Widget _buildTimeDivider(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              _formatDateDivider(date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Divider(thickness: 1)),
        ],
      ),
    );
  }
  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  String _formatDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Bugün';
    } else if (messageDate == yesterday) {
      return 'Dün';
    } else if (now.difference(messageDate).inDays < 7) {
      switch (date.weekday) {
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
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _otherUserFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Sohbet');
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Kullanıcı');
            }

            final user = snapshot.data!;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage2(uid: user['id']),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // 👈 Bu satır eklendi
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: user['profile_image'] != null
                        ? NetworkImage(user['profile_image'])
                        : null,
                    child: user['profile_image'] == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user['name'] ?? 'Kullanıcı',
                    style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocListener<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state.status == MessageStatus.success) {
                  if (_isFirstLoad) {
                    // İlk açılışta otomatik scroll yap
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });
                    _isFirstLoad = false;
                  } else if (_isAtBottom) {
                    // Sonradan gelen mesajlarda, kullanıcı en alt ise otomatik scroll yap
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                }
              },
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  if (state.status == MessageStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == MessageStatus.failure) {
                    return Center(child: Text('Hata: ${state.error}'));
                  }
              

              
              
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final showDateDivider = index == 0 ||
                          _isDifferentDay(
                              state.messages[index - 1].createdAt,
                              message.createdAt
                          );
              
                      return Column(
                        children: [
                          if (showDateDivider)
                            _buildTimeDivider(message.createdAt),
                          ChatBubble(
                            message: message,
                            isMe: message.senderId == widget.userId,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          ChatInput(
            onSend: (text) {
              context.read<MessageBloc>().add(
                SendMessage(
                  chatId: widget.chatId,
                  senderId: widget.userId,
                  content: text,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
