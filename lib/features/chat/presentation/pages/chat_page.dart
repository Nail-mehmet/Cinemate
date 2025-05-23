import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/chat/domain/entities/message_entity.dart';
import 'package:Cinemate/features/chat/presentation/components/grouped_messages.dart';
import 'package:Cinemate/features/chat/presentation/components/message_bubble.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/themes/font_theme.dart';
import '../cubits/chat_cubit.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;
  final String? otherUserAvatar;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
    this.otherUserAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;
  List<MessageEntity> _currentMessages = [];
  Timer? _typingTimer;
  bool _isOtherTyping = false;
  StreamSubscription<DocumentSnapshot>? _typingSubscription;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupTypingListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false);
    });
  }

  void _setupTypingListener() {
    _typingSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      final isTypingMap =
          snapshot.data()?['isTyping'] as Map<String, dynamic>? ?? {};
      setState(() {
        _isOtherTyping = isTypingMap[widget.otherUserId] == true;
      });
    });
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _loadMessages() {
    context.read<ChatCubit>().fetchMessages(widget.chatId);
  }

  void _updateTypingStatus(bool isTyping) async {
    _typingTimer?.cancel();

    if (isTyping) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'isTyping.${currentUser!.uid}': true,
      });

      _typingTimer = Timer(const Duration(seconds: 3), () {
        _updateTypingStatus(false);
      });
    } else {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'isTyping.${currentUser!.uid}': false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage2(uid: widget.otherUserId),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.otherUserAvatar != null
                    ? NetworkImage(widget.otherUserAvatar!)
                    : null,
                child: widget.otherUserAvatar == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.otherUserName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) {
                  final unreadMessages = state.messages
                      .where((msg) =>
                          msg.senderId != currentUser!.uid && msg.read == false)
                      .toList();

                  for (final msg in unreadMessages) {
                    context
                        .read<ChatCubit>()
                        .markMessageAsread(widget.chatId, msg.id);
                  }

                  setState(() {
                    _currentMessages = state.messages;
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
              builder: (context, state) {
                if (state is MessagesLoaded || _currentMessages.isNotEmpty) {
                  final groupedMessages = groupMessagesByDate(_currentMessages);
                  final dateKeys = groupedMessages.keys.toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: dateKeys.length,
                          itemBuilder: (context, index) {
                            final label = dateKeys[index];
                            final messages = groupedMessages[label]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(label,
                                        style: AppTextStyles.medium.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary)),
                                  ),
                                ),
                                ...messages.map((message) {
                                  final isMe =
                                      message.senderId == currentUser!.uid;
                                  final isTemp = message.id.startsWith('temp-');

                                  return Opacity(
                                    opacity: isTemp ? 0.6 : 1.0,
                                    child: MessageBubble(
                                      message: message,
                                      isMe: isMe,
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_isOtherTyping)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                height: 45,
                                child: Lottie.asset(
                                  'assets/lotties/typing.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Mesaj yaz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (text) {
                      _sendMessage();
                      _updateTypingStatus(false);
                    },
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        _updateTypingStatus(true);
                      } else {
                        _updateTypingStatus(false);
                      }
                    },
                    onTap: () {
                      if (_messageController.text.isEmpty) {
                        _updateTypingStatus(true);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final newMessage = MessageEntity(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        senderId: currentUser!.uid,
        timestamp: DateTime.now(),
        read: false,
      );

      setState(() {
        _currentMessages = [..._currentMessages, newMessage];
      });

      context.read<ChatCubit>().sendNewMessage(
            chatId: widget.chatId,
            senderId: currentUser!.uid,
            text: text,
          );

      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _typingSubscription?.cancel();
    super.dispose();
  }
}
