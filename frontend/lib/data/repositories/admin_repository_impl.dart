import '../../core/network/admin_api_client.dart';
import '../../domain/entities/content_report.dart';
import '../../domain/entities/unified_content.dart';
import '../../domain/entities/user_penalty.dart';
import '../../domain/entities/moderation_action.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminApiClient _apiClient;

  AdminRepositoryImpl({AdminApiClient? apiClient})
      : _apiClient = apiClient ?? AdminApiClient();

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiClient.get('/admin/dashboard/stats');
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ==========================================
  // USER STORY 1: Fila de Denúncias
  // ==========================================

  @override
  Future<List<ContentReport>> listReports({
    String? status,
    String? targetType,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '/admin/reports',
      queryParameters: {
        if (status != null) 'status': status,
        if (targetType != null) 'targetType': targetType,
        'limit': limit,
        'offset': offset,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => ContentReport.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<ContentReport> getReportDetails(String id) async {
    final response = await _apiClient.get('/admin/reports/$id');
    return ContentReport.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required String action,
    required String resolutionNotes,
  }) async {
    await _apiClient.patch(
      '/admin/reports/$reportId',
      data: {
        'action': action,
        'resolutionNotes': resolutionNotes,
      },
    );
  }

  // ==========================================
  // USER STORY 2: Gestão e Moderação de Conteúdos
  // ==========================================

  @override
  Future<List<UnifiedContent>> listContent({
    String? type,
    String? status,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '/admin/content',
      queryParameters: {
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (query != null && query.isNotEmpty) 'query': query,
        'limit': limit,
        'offset': offset,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => UnifiedContent.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> hideContent({
    required String type,
    required String id,
    required String reason,
  }) async {
    await _apiClient.patch(
      '/admin/content/$type/$id/hide',
      data: {'reason': reason},
    );
  }

  @override
  Future<void> restoreContent({
    required String type,
    required String id,
    required String reason,
  }) async {
    await _apiClient.patch(
      '/admin/content/$type/$id/restore',
      data: {'reason': reason},
    );
  }

  @override
  Future<void> deleteContent({
    required String type,
    required String id,
    required String reason,
  }) async {
    await _apiClient.delete(
      '/admin/content/$type/$id',
      data: {
        'reason': reason,
        'confirm': true,
      },
    );
  }

  // ==========================================
  // USER STORY 3: Usuários e Sanções
  // ==========================================

  @override
  Future<List<AdminUserSummary>> listUsers({
    String? status,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '/admin/users',
      queryParameters: {
        if (status != null) 'status': status,
        if (query != null && query.isNotEmpty) 'query': query,
        'limit': limit,
        'offset': offset,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => AdminUserSummary.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> getUserDetails(String id) async {
    final response = await _apiClient.get('/admin/users/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<UserPenalty> applyPenalty({
    required String userId,
    required String penaltyType,
    required String reason,
  }) async {
    final response = await _apiClient.post(
      '/admin/users/$userId/penalties',
      data: {
        'penaltyType': penaltyType,
        'reason': reason,
      },
    );

    return UserPenalty.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> revokePenalty({
    required String userId,
    required String penaltyId,
    required String reason,
  }) async {
    await _apiClient.delete(
      '/admin/users/$userId/penalties/$penaltyId',
      data: {'reason': reason},
    );
  }

  // ==========================================
  // USER STORY 4: Trilha de Auditoria
  // ==========================================

  @override
  Future<List<ModerationAction>> listAuditLogs({
    String? moderatorId,
    String? actionType,
    String? targetType,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '/admin/audit-logs',
      queryParameters: {
        if (moderatorId != null) 'moderatorId': moderatorId,
        if (actionType != null) 'actionType': actionType,
        if (targetType != null) 'targetType': targetType,
        'limit': limit,
        'offset': offset,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => ModerationAction.fromJson(item as Map<String, dynamic>)).toList();
  }
}
