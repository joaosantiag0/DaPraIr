import 'package:frontend/core/base/equatable.dart';

class GamificationTransaction extends Equatable {
  final String id;
  final String actionType;
  final int points;
  final String? sourceId;
  final String? sourceType;
  final String description;
  final DateTime createdAt;

  const GamificationTransaction({
    required this.id,
    required this.actionType,
    required this.points,
    this.sourceId,
    this.sourceType,
    required this.description,
    required this.createdAt,
  });

  factory GamificationTransaction.fromJson(Map<String, dynamic> json) {
    return GamificationTransaction(
      id: json['id'] as String,
      actionType: json['action_type'] as String,
      points: json['points'] as int,
      sourceId: json['source_id'] as String?,
      sourceType: json['source_type'] as String?,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType,
      'points': points,
      'source_id': sourceId,
      'source_type': sourceType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, actionType, points, sourceId, sourceType, description, createdAt];
}
