import 'package:flutter/material.dart';
import '../../domain/entities/content_report.dart';
import 'accessible_button.dart';
import 'accessible_text_field.dart';

class ContentReportDialog extends StatefulWidget {
  final String targetType;
  final String targetId;
  final Function(ReportReason reason, String? details) onSubmit;

  const ContentReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required String targetType,
    required String targetId,
    required Function(ReportReason reason, String? details) onSubmit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ContentReportDialog(
        targetType: targetType,
        targetId: targetId,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ContentReportDialog> createState() => _ContentReportDialogState();
}

class _ContentReportDialogState extends State<ContentReportDialog> {
  ReportReason _selectedReason = ReportReason.inaccurateData;
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Denunciar Conteúdo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajude a manter as informações de acessibilidade confiáveis e a comunidade respeitosa.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecione o motivo da denúncia:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...ReportReason.values.map((reason) {
              final isSelected = _selectedReason == reason;
              return Semantics(
                button: true,
                selected: isSelected,
                label: 'Motivo: ${reason.toDisplayName()}',
                child: RadioListTile<ReportReason>(
                  title: Text(reason.toDisplayName(), style: const TextStyle(fontSize: 14)),
                  value: reason,
                  groupValue: _selectedReason,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedReason = val);
                    }
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
            AccessibleTextField(
              controller: _detailsController,
              label: 'Detalhes adicionais (opcional)',
              hint: 'Descreva sucintamente o problema observado...',
              maxLines: 3,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: AccessibleButton(
                label: 'Cancelar',
                isSecondary: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AccessibleButton(
                label: 'Enviar Denúncia',
                onPressed: () {
                  widget.onSubmit(
                    _selectedReason,
                    _detailsController.text.trim().isEmpty ? null : _detailsController.text.trim(),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
