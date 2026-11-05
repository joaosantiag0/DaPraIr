import 'package:frontend/core/base/equatable.dart';

class ContentReport extends Equatable {
  final String id;
  final String targetType;
  final String targetId;
  final String reason;
  final String? details;
  final String status;
  final String reporterMaskedName;
  final DateTime createdAt;
  final Map<String, dynamic>? targetContent;
  final int? priorReportsCount;

  const ContentReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details,
    required this.status,
    required this.reporterMaskedName,
    required this.createdAt,
    this.targetContent,
    this.priorReportsCount,
  });

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    return ContentReport(
      id: json['id'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      reason: json['reason'] as String,
      details: json['details'] as String?,
      status: json['status'] as String,
      reporterMaskedName: json['reporterMaskedName'] as String? ?? 'Anônimo',
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetContent: json['targetContent'] as Map<String, dynamic>?,
      priorReportsCount: json['priorReportsCount'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        targetType,
        targetId,
        reason,
        details,
        status,
        reporterMaskedName,
        createdAt,
        targetContent,
        priorReportsCount,
      ];
}
