import 'package:frontend/core/base/equatable.dart';

enum ReportReason {
  inaccurateData,
  inappropriateMedia,
  harassment,
  spam,
  other,
}

extension ReportReasonExtension on ReportReason {
  String toApiCode() {
    switch (this) {
      case ReportReason.inaccurateData:
        return 'INACCURATE_DATA';
      case ReportReason.inappropriateMedia:
        return 'INAPPROPRIATE_MEDIA';
      case ReportReason.harassment:
        return 'HARASSMENT';
      case ReportReason.spam:
        return 'SPAM';
      case ReportReason.other:
        return 'OTHER';
    }
  }

  String toDisplayName() {
    switch (this) {
      case ReportReason.inaccurateData:
        return 'Informações Incorretas de Acessibilidade';
      case ReportReason.inappropriateMedia:
        return 'Foto / Mídia Inadequada ou Ofensiva';
      case ReportReason.harassment:
        return 'Assédio / Discurso de Ódio';
      case ReportReason.spam:
        return 'Spam ou Conteúdo Comercial Não Autorizado';
      case ReportReason.other:
        return 'Outro Motivo';
    }
  }
}

class ContentReportResult extends Equatable {
  final String reportId;
  final String targetType;
  final String targetId;
  final int distinctReportsCount;
  final String? targetStatus;

  const ContentReportResult({
    required this.reportId,
    required this.targetType,
    required this.targetId,
    required this.distinctReportsCount,
    this.targetStatus,
  });

  @override
  List<Object?> get props => [reportId, targetType, targetId, distinctReportsCount, targetStatus];
}

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
