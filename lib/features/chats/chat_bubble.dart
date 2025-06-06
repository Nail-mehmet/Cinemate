import 'package:Cinemate/features/chats/message_model.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isMe ? 48 : 8, // left
          4,              // top
          isMe ? 8 : 48,  // right
          4,              // bottom
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Sağa yasla
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zaman bilgisi
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                  ),
                ),
                // Okundu işareti - sadece kendi mesajlarında
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: message.isRead ? Colors.lightBlueAccent : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}