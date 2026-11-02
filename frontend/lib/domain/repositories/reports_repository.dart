import '../entities/content_report.dart';

abstract class ReportsRepository {
  Future<ContentReportResult> submitReport({
    required String targetType,
    required String targetId,
    required ReportReason reason,
    String? details,
  });
}
