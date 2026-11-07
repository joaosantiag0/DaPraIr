import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/admin_repository_impl.dart';
import '../../bloc/admin/admin_reports_bloc.dart';
import '../../bloc/admin/admin_content_bloc.dart';
import '../../bloc/admin/admin_users_bloc.dart';
import '../../bloc/admin/admin_audit_bloc.dart';
import 'admin_reports_queue_view.dart';
import 'admin_content_view.dart';
import 'admin_users_view.dart';
import 'admin_audit_view.dart';

import '../../../domain/repositories/admin_repository.dart';

class AdminDashboardView extends StatefulWidget {
  final AdminRepository? repository;
  const AdminDashboardView({super.key, this.repository});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AdminRepository _repository;
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AdminRepositoryImpl();
    _tabController = TabController(length: 4, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _repository.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminReportsBloc(repository: _repository)..add(const LoadReportsEvent()),
        ),
        BlocProvider(
          create: (_) => AdminContentBloc(repository: _repository)..add(const LoadContentEvent()),
        ),
        BlocProvider(
          create: (_) => AdminUsersBloc(repository: _repository)..add(const LoadUsersEvent()),
        ),
        BlocProvider(
          create: (_) => AdminAuditBloc(repository: _repository)..add(const LoadAuditLogsEvent()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel de Controle e Moderação'),
          actions: [
            Semantics(
              button: true,
              label: 'Atualizar estatísticas gerais',
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadStats,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.flag), text: 'Denúncias'),
              Tab(icon: Icon(Icons.article), text: 'Conteúdos'),
              Tab(icon: Icon(Icons.people), text: 'Usuários'),
              Tab(icon: Icon(Icons.history), text: 'Auditoria'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Top Summary Bar
            if (!_isLoadingStats && _stats != null)
              Container(
                color: Colors.blueGrey.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Denúncias',
                      value: '${_stats!['pendingReportsCount'] ?? 0}',
                      color: Colors.amber.shade900,
                    ),
                    _StatItem(
                      label: 'Ações Hoje',
                      value: '${_stats!['actionsTodayCount'] ?? 0}',
                      color: Colors.blue.shade900,
                    ),
                    _StatItem(
                      label: 'Sanções Ativas',
                      value: '${_stats!['activePenaltiesCount'] ?? 0}',
                      color: Colors.red.shade900,
                    ),
                    _StatItem(
                      label: 'Total Usuários',
                      value: '${_stats!['totalUsersCount'] ?? 0}',
                      color: Colors.green.shade900,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  AdminReportsQueueView(repository: _repository),
                  const AdminContentView(),
                  const AdminUsersView(),
                  const AdminAuditView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
        ),
      ],
    );
  }
}
