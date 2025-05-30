part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends MessageEvent {
  final String chatId;

  const LoadMessages(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class SendMessage extends MessageEvent {
  final String chatId;
  final String senderId;
  final String content;

  const SendMessage({
    required this.chatId,
    required this.senderId,
    required this.content,
  });

  @override
  List<Object> get props => [chatId, senderId, content];
}

class MarkMessagesAsRead extends MessageEvent {
  final String chatId;
  final String userId;

  const MarkMessagesAsRead(this.chatId, this.userId);

  @override
  List<Object> get props => [chatId, userId];
}
class MessagesUpdated extends MessageEvent {
  final List<Message> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object> get props => [messages];
}
