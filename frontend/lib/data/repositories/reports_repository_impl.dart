import 'package:dio/dio.dart';
import '../../domain/entities/content_report.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final Dio dio;

  ReportsRepositoryImpl(this.dio);

  @override
  Future<ContentReportResult> submitReport({
    required String targetType,
    required String targetId,
    required ReportReason reason,
    String? details,
  }) async {
    final response = await dio.post('/api/v1/reports', data: {
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason.toApiCode(),
      if (details != null && details.isNotEmpty) 'details': details,
    });

    final data = response.data as Map<String, dynamic>;

    return ContentReportResult(
      reportId: data['reportId'] as String,
      targetType: data['targetType'] as String,
      targetId: data['targetId'] as String,
      distinctReportsCount: data['distinctReportsCount'] as int,
      targetStatus: data['targetStatus'] as String?,
    );
  }
}
