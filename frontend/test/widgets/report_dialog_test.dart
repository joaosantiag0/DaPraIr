import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/components/content_report_dialog.dart';
import 'package:frontend/domain/entities/content_report.dart';

void main() {
  testWidgets('ContentReportDialog renders reason choices and submits selected reason', (tester) async {
    ReportReason? submittedReason;
    String? submittedDetails;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ContentReportDialog.show(
                  context: context,
                  targetType: 'REVIEW',
                  targetId: 'rev-1',
                  onSubmit: (reason, details) {
                    submittedReason = reason;
                    submittedDetails = details;
                  },
                );
              },
              child: const Text('Abrir Denúncia'),
            ),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Abrir Denúncia'));
    await tester.pumpAndSettle();

    // Verify dialog elements
    expect(find.text('Denunciar Conteúdo'), findsOneWidget);
    expect(find.text('Informações Incorretas de Acessibilidade'), findsOneWidget);
    expect(find.text('Assédio / Discurso de Ódio'), findsOneWidget);

    // Select Harassment
    await tester.tap(find.text('Assédio / Discurso de Ódio'));
    await tester.pumpAndSettle();

    // Fill optional details
    await tester.enterText(find.byType(TextField), 'Comentário ofensivo');
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.text('Enviar Denúncia'));
    await tester.pumpAndSettle();

    // Verify callback
    expect(submittedReason, ReportReason.harassment);
    expect(submittedDetails, 'Comentário ofensivo');
  });
}
