import 'package:equatable/equatable.dart';

class SocialPeer extends Equatable {
  final String id;
  final String name;
  final String handle;
  final String? avatarUrl;
  final String? bio;

  const SocialPeer({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
    this.bio,
  });

  @override
  List<Object?> get props => [id, name, handle];
}

class SocialConnection extends Equatable {
  final String id;
  final String status; // PENDING, ACCEPTED, DECLINED, BLOCKED
  final bool isOutgoing;
  final DateTime createdAt;
  final SocialPeer peer;

  const SocialConnection({
    required this.id,
    required this.status,
    required this.isOutgoing,
    required this.createdAt,
    required this.peer,
  });

  bool get isAccepted => status == 'ACCEPTED';
  bool get isPending => status == 'PENDING';

  @override
  List<Object?> get props => [id, status, isOutgoing, peer];
}
