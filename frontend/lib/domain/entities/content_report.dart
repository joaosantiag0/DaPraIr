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
