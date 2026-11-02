import 'dart:async';
import '../../core/network/dio_client.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final DioClient dioClient;
  final StreamController<ChatMessage> _messageStreamController = StreamController<ChatMessage>.broadcast();

  ChatRepositoryImpl({required this.dioClient});

  @override
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  @override
  Future<List<ChatMessage>> getMessages(String peerUserId) async {
    final response = await dioClient.dio.get('/api/v1/chat/messages/$peerUserId');
    final list = (response.data as List<dynamic>?) ?? [];

    return list.map((json) {
      final sender = json['sender'] as Map<String, dynamic>;
      final isOut = sender['id'] != peerUserId;
      return ChatMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        recipientId: json['recipientId'] as String,
        content: json['content'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isOutgoing: isOut,
      );
    }).toList();
  }

  @override
  Future<ChatMessage> sendMessage(String peerUserId, String content) async {
    final response = await dioClient.dio.post(
      '/api/v1/chat/messages/$peerUserId',
      data: {'content': content},
    );
    final json = response.data as Map<String, dynamic>;
    final msg = ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOutgoing: true,
    );

    _messageStreamController.add(msg);
    return msg;
  }

  @override
  void dispose() {
    _messageStreamController.close();
  }
}
