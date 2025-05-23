import '../repositories/chat_repository.dart';

class StartChat {
  final ChatRepository repository;

  StartChat({required this.repository});

  Future<String> call({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String currentUserAvatar,
    required String otherUserName,
    required String otherUserAvatar,
  }) async {
    return repository.startChat(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
      currentUserName: currentUserName,
      currentUserAvatar: currentUserAvatar,
      otherUserName: otherUserName,
      otherUserAvatar: otherUserAvatar,
    );
  }
}