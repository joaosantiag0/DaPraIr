import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages(String peerUserId);

  Future<ChatMessage> sendMessage(String peerUserId, String content);

  Stream<ChatMessage> get messageStream;

  void dispose();
}
