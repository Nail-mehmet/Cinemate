part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadChats extends ChatEvent {
  final String userId;

  const LoadChats(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateChat extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  const CreateChat(this.currentUserId, this.otherUserId);

  @override
  List<Object> get props => [currentUserId, otherUserId];
}

class UpdateChats extends ChatEvent {
  final List<Chat> chats;

  const UpdateChats(this.chats);

  @override
  List<Object> get props => [chats];
}