import '../entities/content_report.dart';
import '../entities/unified_content.dart';
import '../entities/user_penalty.dart';
import '../entities/moderation_action.dart';

abstract class AdminRepository {
  Future<Map<String, dynamic>> getDashboardStats();

  // User Story 1
  Future<List<ContentReport>> listReports({
    String? status,
    String? targetType,
    int limit = 20,
    int offset = 0,
  });

  Future<ContentReport> getReportDetails(String id);

  Future<void> resolveReport({
    required String reportId,
    required String action,
    required String resolutionNotes,
  });

  // User Story 2
  Future<List<UnifiedContent>> listContent({
    String? type,
    String? status,
    String? query,
    int limit = 20,
    int offset = 0,
  });

  Future<void> hideContent({
    required String type,
    required String id,
    required String reason,
  });

  Future<void> restoreContent({
    required String type,
    required String id,
    required String reason,
  });

  Future<void> deleteContent({
    required String type,
    required String id,
    required String reason,
  });

  // User Story 3
  Future<List<AdminUserSummary>> listUsers({
    String? status,
    String? query,
    int limit = 20,
    int offset = 0,
  });

  Future<Map<String, dynamic>> getUserDetails(String id);

  Future<UserPenalty> applyPenalty({
    required String userId,
    required String penaltyType,
    required String reason,
  });

  Future<void> revokePenalty({
    required String userId,
    required String penaltyId,
    required String reason,
  });

  // User Story 4
  Future<List<ModerationAction>> listAuditLogs({
    String? moderatorId,
    String? actionType,
    String? targetType,
    int limit = 20,
    int offset = 0,
  });
}
