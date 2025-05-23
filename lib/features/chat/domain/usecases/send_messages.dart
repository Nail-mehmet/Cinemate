import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage({required this.repository});

  Future<void> call({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    return repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      text: text,
    );
  }
}