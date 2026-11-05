import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/components/community_rules_sheet.dart';

void main() {
  testWidgets('CommunityRulesSheet displays freedom of speech and 5 community rules', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => CommunityRulesSheet.show(context),
              child: const Text('Abrir Regras'),
            ),
          ),
        ),
      ),
    );

    // Tap to open sheet
    await tester.tap(find.text('Abrir Regras'));
    await tester.pumpAndSettle();

    // Verify Title and Subtitle
    expect(find.text('Regras da Comunidade'), findsOneWidget);
    expect(find.text('Liberdade com respeito mútuo'), findsOneWidget);

    // Verify Freedom of conversation highlight banner
    expect(find.text('Você pode conversar sobre o que quiser!'), findsOneWidget);
    expect(
      find.textContaining('Sinta-se em casa para puxar papo, trocar ideias'),
      findsOneWidget,
    );

    // Verify 5 Rules
    expect(find.text('1. Respeito, Empatia e Inclusão'), findsOneWidget);
    expect(find.text('2. Liberdade de Expressão Responsável'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('3. Ambiente Seguro e Colaborativo'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('3. Ambiente Seguro e Colaborativo'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('4. Sem Spam ou Golpes'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('4. Sem Spam ou Golpes'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('5. Proteção à Privacidade'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('5. Proteção à Privacidade'), findsOneWidget);

    // Verify confirm button
    expect(find.text('Entendido, vamos conversar!'), findsOneWidget);

    // Tap confirm button to close
    await tester.tap(find.text('Entendido, vamos conversar!'));
    await tester.pumpAndSettle();

    expect(find.text('Regras da Comunidade'), findsNothing);
  });
}
