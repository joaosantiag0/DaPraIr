import 'package:frontend/core/base/equatable.dart';

class UserPenalty extends Equatable {
  final String id;
  final String userId;
  final String penaltyType; // WARNING, SUSPENSION_7_DAYS, PERMANENT_BAN
  final String reason;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String status; // ACTIVE, EXPIRED, REVOKED
  final String? moderatorName;

  const UserPenalty({
    required this.id,
    required this.userId,
    required this.penaltyType,
    required this.reason,
    required this.startsAt,
    this.endsAt,
    required this.status,
    this.moderatorName,
  });

  factory UserPenalty.fromJson(Map<String, dynamic> json) {
    return UserPenalty(
      id: json['id'] as String,
      userId: json['userId'] as String,
      penaltyType: json['penaltyType'] as String,
      reason: json['reason'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: json['endsAt'] != null ? DateTime.parse(json['endsAt'] as String) : null,
      status: json['status'] as String,
      moderatorName: json['moderatorName'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        penaltyType,
        reason,
        startsAt,
        endsAt,
        status,
        moderatorName,
      ];
}

class AdminUserSummary extends Equatable {
  final String id;
  final String name;
  final String handle;
  final String email;
  final String role;
  final String status; // ACTIVE, WARNED, SUSPENDED, BANNED
  final int penaltiesCount;
  final DateTime createdAt;

  const AdminUserSummary({
    required this.id,
    required this.name,
    required this.handle,
    required this.email,
    required this.role,
    required this.status,
    required this.penaltiesCount,
    required this.createdAt,
  });

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    return AdminUserSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      handle: json['handle'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      penaltiesCount: json['penaltiesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        handle,
        email,
        role,
        status,
        penaltiesCount,
        createdAt,
      ];
}
