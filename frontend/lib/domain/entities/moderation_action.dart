import 'package:frontend/core/base/equatable.dart';

class ModerationAction extends Equatable {
  final String id;
  final String moderatorId;
  final String moderatorName;
  final String actionType;
  final String targetType;
  final String targetId;
  final String reason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const ModerationAction({
    required this.id,
    required this.moderatorId,
    required this.moderatorName,
    required this.actionType,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.metadata,
    required this.createdAt,
  });

  factory ModerationAction.fromJson(Map<String, dynamic> json) {
    return ModerationAction(
      id: json['id'] as String,
      moderatorId: json['moderatorId'] as String,
      moderatorName: json['moderatorName'] as String? ?? 'Administrador',
      actionType: json['actionType'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      reason: json['reason'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        moderatorId,
        moderatorName,
        actionType,
        targetType,
        targetId,
        reason,
        metadata,
        createdAt,
      ];
}
