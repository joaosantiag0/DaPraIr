import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin/admin_reports_bloc.dart';
import '../../../domain/entities/content_report.dart';
import '../../../domain/repositories/admin_repository.dart';

class AdminReportsQueueView extends StatelessWidget {
  final AdminRepository? repository;

  const AdminReportsQueueView({super.key, this.repository});

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
                return _ReportCard(
                  report: report,
                  repository: repository,
                );
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

class ContentDetailsHelper {
  static String getTitleOrHeader(String targetType, Map<String, dynamic>? target) {
    if (target == null) return '';
    if (target['title'] != null) return target['title'].toString();
    if (target['topicTitle'] != null) return 'Tópico: ${target['topicTitle']}';
    if (target['placeName'] != null) return 'Local: ${target['placeName']}';
    if (target['locationName'] != null) return 'Local: ${target['locationName']}';
    if (target['name'] != null) return target['name'].toString();
    return '';
  }

  static String getMainText(String targetType, Map<String, dynamic>? target) {
    if (target == null) return '';
    if (target['content'] != null) return target['content'].toString();
    if (target['generalComment'] != null) return target['generalComment'].toString();
    if (target['description'] != null) return target['description'].toString();
    if (target['altText'] != null) return 'Descrição: ${target['altText']}';
    if (target['email'] != null) return 'Email: ${target['email']} | Handle: @${target['handle'] ?? ''}';
    return '';
  }

  static String? getAuthorInfo(Map<String, dynamic>? target) {
    if (target == null) return null;
    final author = target['author'] ?? target['user'] ?? target['sender'];
    if (author is Map<String, dynamic>) {
      final name = author['name'] ?? '';
      final handle = author['handle'] != null ? '@${author['handle']}' : '';
      return [name, handle].where((s) => s.isNotEmpty).join(' ');
    }
    return null;
  }

  static IconData getIconForType(String type) {
    switch (type) {
      case 'FORUM_TOPIC':
        return Icons.forum;
      case 'FORUM_COMMENT':
        return Icons.comment;
      case 'PLACE_REVIEW':
      case 'REVIEW':
        return Icons.rate_review;
      case 'PLACE_MEDIA':
      case 'MEDIA':
        return Icons.photo;
      case 'USER':
        return Icons.person;
      case 'EVENT':
        return Icons.event;
      case 'MESSAGE':
        return Icons.mail;
      default:
        return Icons.article;
    }
  }
}

class _ReportCard extends StatelessWidget {
  final ContentReport report;
  final AdminRepository? repository;

  const _ReportCard({
    required this.report,
    this.repository,
  });

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
    final bloc = context.read<AdminReportsBloc>();
    final messenger = ScaffoldMessenger.maybeOf(context);

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
                (ScaffoldMessenger.maybeOf(dialogCtx) ?? messenger)?.showSnackBar(
                  const SnackBar(
                    content: Text('A justificativa deve conter pelo menos 10 caracteres.'),
                  ),
                );
                return;
              }
              Navigator.of(dialogCtx).pop();
              bloc.add(
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

  void _showContentDialog(BuildContext context) {
    final activeRepo = repository ?? context.read<AdminReportsBloc>().repository;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        if (report.targetContent != null) {
          return _ContentDetailsDialog(
            report: report,
            targetContent: report.targetContent!,
            onAccept: () {
              Navigator.of(dialogCtx).pop();
              if (context.mounted) {
                _showResolutionDialog(context, 'ACCEPT_ACTION_APPLIED');
              }
            },
            onDismiss: () {
              Navigator.of(dialogCtx).pop();
              if (context.mounted) {
                _showResolutionDialog(context, 'DISMISS_UNFOUNDED');
              }
            },
          );
        }

        // Fetch on-demand if targetContent is null
        return FutureBuilder<ContentReport>(
          future: activeRepo.getReportDetails(report.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Carregando conteúdo denunciado...'),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                title: const Text('Conteúdo Denunciado'),
                content: Text(
                  'Conteúdo ID: ${report.targetId} (${report.targetType}).\n'
                  'Não foi possível obter detalhes adicionais do servidor.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('Fechar'),
                  ),
                ],
              );
            }

            final fetchedReport = snapshot.data!;
            return _ContentDetailsDialog(
              report: fetchedReport,
              targetContent: fetchedReport.targetContent ?? {},
              onAccept: () {
                Navigator.of(dialogCtx).pop();
                if (context.mounted) {
                  _showResolutionDialog(context, 'ACCEPT_ACTION_APPLIED');
                }
              },
              onDismiss: () {
                Navigator.of(dialogCtx).pop();
                if (context.mounted) {
                  _showResolutionDialog(context, 'DISMISS_UNFOUNDED');
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewTitle = ContentDetailsHelper.getTitleOrHeader(report.targetType, report.targetContent);
    final previewText = ContentDetailsHelper.getMainText(report.targetType, report.targetContent);
    final previewAuthor = ContentDetailsHelper.getAuthorInfo(report.targetContent);

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
            const SizedBox(height: 10),

            // Visualização do Conteúdo Denunciado no Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        ContentDetailsHelper.getIconForType(report.targetType),
                        size: 18,
                        color: Colors.blueGrey.shade900,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Conteúdo Denunciado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (previewTitle.isNotEmpty) ...[
                    Text(
                      previewTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (previewText.isNotEmpty) ...[
                    Text(
                      previewText,
                      style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ] else if (report.targetContent == null) ...[
                    Text(
                      'ID do Alvo: ${report.targetId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (previewAuthor != null) ...[
                    Text(
                      'Autor: $previewAuthor',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Semantics(
                    button: true,
                    label: 'Visualizar conteúdo completo denunciado',
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(120, 36),
                        alignment: Alignment.centerLeft,
                      ),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Visualizar Conteúdo'),
                      onPressed: () => _showContentDialog(context),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 20),
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

class _ContentDetailsDialog extends StatelessWidget {
  final ContentReport report;
  final Map<String, dynamic> targetContent;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const _ContentDetailsDialog({
    required this.report,
    required this.targetContent,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final title = ContentDetailsHelper.getTitleOrHeader(report.targetType, targetContent);
    final text = ContentDetailsHelper.getMainText(report.targetType, targetContent);
    final author = ContentDetailsHelper.getAuthorInfo(targetContent);
    final mediaUrl = targetContent['mediaUrl'] ?? targetContent['thumbnailUrl'];

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            ContentDetailsHelper.getIconForType(report.targetType),
            color: Colors.blueGrey.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Conteúdo Denunciado',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Target Type & Target ID
            Row(
              children: [
                Chip(
                  label: Text(
                    report.targetType,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: Colors.blueGrey.shade800,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ID: ${report.targetId}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Author info if present
            if (author != null) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Autor: $author',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Title / Header
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
            ],

            // Score if review
            if (targetContent['averageScore'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Nota: ${targetContent['averageScore']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Media Image preview if present
            if (mediaUrl != null && mediaUrl.toString().isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  mediaUrl.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                          'Mídia: $mediaUrl',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Full content text box
            if (text.isNotEmpty) ...[
              const Text(
                'Conteúdo:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Prior reports count
            if (report.priorReportsCount != null && report.priorReportsCount! > 1) ...[
              Text(
                'Histórico: ${report.priorReportsCount} denúncias registradas contra este conteúdo.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Reporter statement
            const Divider(),
            const SizedBox(height: 4),
            Text(
              'Motivo da denúncia: ${report.reason}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            if (report.details != null && report.details!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Relato do denunciante: ${report.details}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size(80, 48)),
          onPressed: onDismiss,
          child: const Text('Rejeitar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 48),
          ),
          onPressed: onAccept,
          child: const Text('Aceitar'),
        ),
      ],
    );
  }
}
