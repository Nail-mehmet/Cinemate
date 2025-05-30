part of 'message_bloc.dart';

enum MessageStatus { initial, loading, success, failure }

class MessageState extends Equatable {
  final MessageStatus status;
  final List<Message> messages;
  final String? error;

  const MessageState({
    this.status = MessageStatus.initial,
    this.messages = const [],
    this.error,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<Message>? messages,
    String? error,
  }) {
    return MessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, messages, error];
}