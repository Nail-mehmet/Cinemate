import 'package:Cinemate/features/chats/chat_bubble.dart';
import 'package:Cinemate/features/chats/chat_input.dart';
import 'package:Cinemate/features/chats/chat_repository.dart';
import 'package:Cinemate/features/chats/message_bloc.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(LoadMessages(widget.chatId));
    context.read<MessageBloc>().add(MarkMessagesAsRead(widget.chatId, widget.userId));
    _otherUserFuture = ChatRepository(
      supabaseClient: Supabase.instance.client,
    ).getOtherParticipantProfile(widget.chatId, widget.userId);
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
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: user['profile_image'] != null
                        ? NetworkImage(user['profile_image'])
                        : null,
                    child: user['profile_image'] == null ? const Icon(Icons.person, size: 16) : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user['name'] ?? 'Kullanıcı',
                    style: const TextStyle(fontSize: 16),
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
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state.status == MessageStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == MessageStatus.failure) {
                  return Center(child: Text('Hata: ${state.error}'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    return ChatBubble(
                      message: message,
                      isMe: message.senderId == widget.userId,
                    );
                  },
                );
              },
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
