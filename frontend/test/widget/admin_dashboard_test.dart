import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/content_report.dart';
import 'package:frontend/domain/entities/moderation_action.dart';
import 'package:frontend/domain/entities/unified_content.dart';
import 'package:frontend/domain/entities/user_penalty.dart';
import 'package:frontend/domain/repositories/admin_repository.dart';
import 'package:frontend/presentation/views/admin/admin_dashboard_view.dart';
import 'package:frontend/presentation/views/admin/admin_reports_queue_view.dart';
import 'package:frontend/presentation/views/admin/admin_content_view.dart';
import 'package:frontend/presentation/views/admin/admin_users_view.dart';
import 'package:frontend/presentation/views/admin/admin_audit_view.dart';

class FakeAdminRepository implements AdminRepository {
  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    return {
      'pendingReportsCount': 12,
      'actionsTodayCount': 8,
      'activePenaltiesCount': 3,
      'totalUsersCount': 42,
    };
  }

  @override
  Future<List<ContentReport>> listReports({
    String? status,
    String? targetType,
    int limit = 20,
    int offset = 0,
  }) async {
    return [
      ContentReport(
        id: 'rep-test-1',
        targetType: 'FORUM_TOPIC',
        targetId: 'top-test-1',
        reason: 'SPAM',
        details: 'Spam report description',
        status: 'PENDING',
        reporterMaskedName: 'u***1',
        createdAt: DateTime(2026, 11, 5),
      ),
    ];
  }

  @override
  Future<ContentReport> getReportDetails(String id) async {
    return ContentReport(
      id: id,
      targetType: 'FORUM_TOPIC',
      targetId: 'top-test-1',
      reason: 'SPAM',
      details: 'Spam report details',
      status: 'PENDING',
      reporterMaskedName: 'u***1',
      createdAt: DateTime(2026, 11, 5),
      targetContent: const {
        'id': 'top-test-1',
        'title': 'Tópico de Teste Spam',
        'content': 'Compre produtos promocionais ilegais agora!',
        'author': {'name': 'Spammer Test', 'handle': 'spammer'},
      },
    );
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required String action,
    required String resolutionNotes,
  }) async {}

  @override
  Future<List<UnifiedContent>> listContent({
    String? type,
    String? status,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    return [
      UnifiedContent(
        id: 'cnt-1',
        type: 'FORUM_TOPIC',
        titleOrSnippet: 'Tópico de Teste Moderado',
        content: 'Trecho do conteúdo...',
        authorName: 'João da Silva',
        authorHandle: 'joao',
        status: 'ACTIVE',
        createdAt: DateTime(2026, 11, 5),
      ),
    ];
  }

  @override
  Future<void> hideContent({
    required String type,
    required String id,
    required String reason,
  }) async {}

  @override
  Future<void> restoreContent({
    required String type,
    required String id,
    required String reason,
  }) async {}

  @override
  Future<void> deleteContent({
    required String type,
    required String id,
    required String reason,
  }) async {}

  @override
  Future<List<AdminUserSummary>> listUsers({
    String? status,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    return [
      AdminUserSummary(
        id: 'usr-1',
        name: 'Maria Moderada',
        handle: 'maria',
        email: 'maria@example.com',
        role: 'USER',
        status: 'ACTIVE',
        penaltiesCount: 0,
        createdAt: DateTime(2026, 11, 5),
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> getUserDetails(String id) async {
    return {
      'id': id,
      'name': 'Maria Moderada',
      'email': 'maria@example.com',
      'role': 'USER',
      'account_status': 'ACTIVE',
      'penalties': [],
    };
  }

  @override
  Future<UserPenalty> applyPenalty({
    required String userId,
    required String penaltyType,
    required String reason,
  }) async {
    return UserPenalty(
      id: 'pen-1',
      userId: userId,
      penaltyType: penaltyType,
      reason: reason,
      startsAt: DateTime(2026, 11, 5),
      status: 'ACTIVE',
      moderatorName: 'mod-1',
    );
  }

  @override
  Future<void> revokePenalty({
    required String userId,
    required String penaltyId,
    required String reason,
  }) async {}

  @override
  Future<List<ModerationAction>> listAuditLogs({
    String? moderatorId,
    String? actionType,
    String? targetType,
    int limit = 20,
    int offset = 0,
  }) async {
    return [
      ModerationAction(
        id: 'act-1',
        moderatorId: 'mod-1',
        moderatorName: 'Admin Principal',
        actionType: 'CONTENT_HIDE',
        targetType: 'FORUM_TOPIC',
        targetId: 'top-1',
        reason: 'Violação das regras',
        createdAt: DateTime(2026, 11, 5),
      ),
    ];
  }
}

void main() {
  group('AdminDashboardView Widget & Accessibility Tests', () {
    late FakeAdminRepository repository;

    setUp(() {
      repository = FakeAdminRepository();
    });

    testWidgets('renders AppBar with title and 4 tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardView(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title
      expect(find.text('Painel de Controle e Moderação'), findsOneWidget);

      // Verify 4 Tabs in AppBar
      expect(find.widgetWithText(Tab, 'Denúncias'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Conteúdos'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Usuários'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Auditoria'), findsOneWidget);

      // Verify Dashboard Top Stats Bar items
      expect(find.text('Ações Hoje'), findsOneWidget);
      expect(find.text('Sanções Ativas'), findsOneWidget);
      expect(find.text('Total Usuários'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('refresh action button includes accessible semantic label and >= 48dp target', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardView(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      final refreshBtnFinder = find.bySemanticsLabel('Atualizar estatísticas gerais');
      expect(refreshBtnFinder, findsOneWidget);

      final size = tester.getSize(refreshBtnFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('switching tabs switches between queue views without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardView(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // First tab (Denúncias)
      expect(find.byType(AdminReportsQueueView), findsOneWidget);
      expect(find.text('Motivo: SPAM'), findsOneWidget);

      // Tap on Conteúdos tab
      await tester.tap(find.widgetWithText(Tab, 'Conteúdos'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminContentView), findsOneWidget);
      expect(find.text('Buscar publicações por título ou conteúdo...'), findsOneWidget);

      // Tap on Usuários tab
      await tester.tap(find.widgetWithText(Tab, 'Usuários'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminUsersView), findsOneWidget);
      expect(find.text('Buscar usuários por nome, email ou @handle...'), findsOneWidget);

      // Tap on Auditoria tab
      await tester.tap(find.widgetWithText(Tab, 'Auditoria'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminAuditView), findsOneWidget);
      expect(find.text('CONTENT_HIDE'), findsOneWidget);
    });

    testWidgets('allows viewing reported content directly in reports queue', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardView(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Check card has Content block and button
      expect(find.text('Conteúdo Denunciado'), findsOneWidget);
      final viewContentBtn = find.widgetWithText(TextButton, 'Visualizar Conteúdo');
      expect(viewContentBtn, findsOneWidget);

      // Tap button to view content dialog
      await tester.tap(viewContentBtn);
      await tester.pumpAndSettle();

      // Dialog opens showing reported content
      expect(find.text('Tópico de Teste Spam'), findsOneWidget);
      expect(find.text('Compre produtos promocionais ilegais agora!'), findsOneWidget);
      expect(find.text('Autor: Spammer Test @spammer'), findsOneWidget);

      // Dialog can be closed
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
      expect(find.text('Compre produtos promocionais ilegais agora!'), findsNothing);
    });
  });
}
