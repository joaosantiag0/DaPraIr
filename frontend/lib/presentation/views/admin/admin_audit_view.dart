import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin/admin_audit_bloc.dart';
import '../../../domain/entities/moderation_action.dart';

class AdminAuditView extends StatelessWidget {
  const AdminAuditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminAuditBloc, AdminAuditState>(
      listener: (context, state) {
        if (state is AdminAuditError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is AdminAuditLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminAuditLoaded) {
          final logs = state.logs;
          if (logs.isEmpty) {
            return const Center(
              child: Text('Nenhum registro de auditoria encontrado.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminAuditBloc>().add(const LoadAuditLogsEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _AuditCard(log: logs[index]);
              },
            ),
          );
        }

        return Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
            onPressed: () {
              context.read<AdminAuditBloc>().add(const LoadAuditLogsEvent());
            },
            child: const Text('Carregar Trilha de Auditoria'),
          ),
        );
      },
    );
  }
}

class _AuditCard extends StatelessWidget {
  final ModerationAction log;

  const _AuditCard({required this.log});

  Color _getActionColor(String action) {
    if (action.contains('BAN') || action.contains('DELETE')) {
      return Colors.red.shade900;
    } else if (action.contains('HIDE') || action.contains('SUSPEND') || action.contains('WARN')) {
      return Colors.orange.shade900;
    } else if (action.contains('RESTORE') || action.contains('UNBAN') || action.contains('RESOLVE')) {
      return Colors.green.shade800;
    }
    return Colors.blue.shade900;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getActionColor(log.actionType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.actionType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${log.createdAt.day.toString().padLeft(2, '0')}/${log.createdAt.month.toString().padLeft(2, '0')}/${log.createdAt.year} ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Moderador: ${log.moderatorName} • Alvo: ${log.targetType}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Justificativa: ${log.reason}',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            if (log.metadata != null && log.metadata!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Metadados: ${log.metadata}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
