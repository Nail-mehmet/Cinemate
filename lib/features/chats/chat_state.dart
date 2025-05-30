part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<Chat> chats;
  final String? error;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chats = const [],
    this.error,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Chat>? chats,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, chats, error];
}