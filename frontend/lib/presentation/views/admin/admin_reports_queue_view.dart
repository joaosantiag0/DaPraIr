import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin/admin_reports_bloc.dart';
import '../../../domain/entities/content_report.dart';

class AdminReportsQueueView extends StatelessWidget {
  const AdminReportsQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminReportsBloc, AdminReportsState>(
      listener: (context, state) {
        if (state is AdminReportsActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AdminReportsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is AdminReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminReportsLoaded) {
          final reports = state.reports;
          if (reports.isEmpty) {
            return Center(
              child: Semantics(
                label: 'Nenhuma denúncia pendente na fila',
                child: const Text('Nenhuma denúncia pendente no momento.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminReportsBloc>().add(const LoadReportsEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportCard(report: report);
              },
            ),
          );
        }

        return Center(
          child: Semantics(
            button: true,
            label: 'Carregar denúncias pendentes',
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed: () {
                context.read<AdminReportsBloc>().add(const LoadReportsEvent());
              },
              child: const Text('Carregar Denúncias'),
            ),
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ContentReport report;

  const _ReportCard({required this.report});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.amber.shade900;
      case 'RESOLVED_SANCTIONED':
        return Colors.green.shade800;
      case 'DISMISSED':
        return Colors.grey.shade700;
      default:
        return Colors.blue.shade900;
    }
  }

  void _showResolutionDialog(BuildContext context, String action) {
    final notesController = TextEditingController();
    final isAccept = action == 'ACCEPT_ACTION_APPLIED';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isAccept ? 'Aceitar e Moderar' : 'Descartar Denúncia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAccept
                  ? 'Informe a justificativa formal para aceitar a infração:'
                  : 'Informe a justificativa para rejeitar a denúncia como improcedente:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Justificativa (mínimo 10 caracteres)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(88, 48)),
            onPressed: () {
              final notes = notesController.text.trim();
              if (notes.length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A justificativa deve conter pelo menos 10 caracteres.'),
                  ),
                );
                return;
              }
              Navigator.of(dialogCtx).pop();
              context.read<AdminReportsBloc>().add(
                    ResolveReportEvent(
                      reportId: report.id,
                      action: action,
                      resolutionNotes: notes,
                    ),
                  );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    report.targetType,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.blueGrey.shade800,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Motivo: ${report.reason}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (report.details != null && report.details!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Detalhes: ${report.details}',
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Denunciante: ${report.reporterMaskedName} • Em: ${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Semantics(
                  button: true,
                  label: 'Rejeitar denúncia como improcedente',
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
                    onPressed: () => _showResolutionDialog(context, 'DISMISS_UNFOUNDED'),
                    child: const Text('Rejeitar'),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'Aceitar denúncia e aplicar moderação',
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 48),
                    ),
                    onPressed: () => _showResolutionDialog(context, 'ACCEPT_ACTION_APPLIED'),
                    child: const Text('Aceitar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
