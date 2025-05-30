import 'package:Cinemate/features/chats/chat_bubble.dart';
import 'package:Cinemate/features/chats/chat_input.dart';
import 'package:Cinemate/features/chats/message_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(LoadMessages(widget.chatId));
    context.read<MessageBloc>().add(MarkMessagesAsRead(widget.chatId, widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbet')),
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
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
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