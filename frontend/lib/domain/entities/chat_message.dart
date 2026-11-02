import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final String status; // SENT, DELIVERED, READ
  final DateTime createdAt;
  final bool isOutgoing;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.isOutgoing,
  });

  @override
  List<Object?> get props => [id, senderId, recipientId, content, status, createdAt];
}
