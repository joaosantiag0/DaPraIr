import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/presentation/components/community_rules_sheet.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CommunityRulesSheet displays freedom of speech, report incentive, and community rules including extremism avoidance', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
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

    // Verify Report Incentive Banner
    expect(find.text('Viu algo fora do padrão? Denuncie!'), findsOneWidget);
    expect(
      find.textContaining('Sua denúncia é anônima e essencial para mantermos a comunidade segura'),
      findsOneWidget,
    );

    // Verify Rules
    await tester.scrollUntilVisible(
      find.text('1. Respeito, Empatia e Inclusão'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('1. Respeito, Empatia e Inclusão'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('2. Liberdade de Expressão Responsável'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('2. Liberdade de Expressão Responsável'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('3. Conteúdos Evitáveis: Extremismo Político e Religioso'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('3. Conteúdos Evitáveis: Extremismo Político e Religioso'), findsOneWidget);
    expect(
      find.textContaining('evite extremismo político e religioso'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('4. Denúncia Ativa e Ambiente Seguro'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('4. Denúncia Ativa e Ambiente Seguro'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('5. Sem Spam ou Golpes'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('5. Sem Spam ou Golpes'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('6. Proteção à Privacidade'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('6. Proteção à Privacidade'), findsOneWidget);

    // Verify confirm button
    expect(find.text('Entendido, vamos conversar!'), findsOneWidget);

    // Tap confirm button to close
    await tester.tap(find.text('Entendido, vamos conversar!'));
    await tester.pumpAndSettle();

    expect(find.text('Regras da Comunidade'), findsNothing);

    // Verify SharedPreferences updated
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(CommunityRulesSheet.rulesAcknowledgedKey), isTrue);
  });

  testWidgets('ensureAcknowledged opens sheet on first time and skips when already acknowledged', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Initially not acknowledged
    SharedPreferences.setMockInitialValues({});
    bool? wasShown;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                wasShown = await CommunityRulesSheet.ensureAcknowledged(context);
              },
              child: const Text('Postar Algo'),
            ),
          ),
        ),
      ),
    );

    // Tap Postar Algo - 1st time
    await tester.tap(find.text('Postar Algo'));
    await tester.pumpAndSettle();

    // Sheet should be shown
    expect(find.text('Regras da Comunidade'), findsOneWidget);

    // Close sheet
    await tester.tap(find.text('Entendido, vamos conversar!'));
    await tester.pumpAndSettle();

    expect(wasShown, isTrue);
    expect(find.text('Regras da Comunidade'), findsNothing);

    // Tap Postar Algo - 2nd time
    wasShown = null;
    await tester.tap(find.text('Postar Algo'));
    await tester.pumpAndSettle();

    // Sheet should NOT be shown
    expect(find.text('Regras da Comunidade'), findsNothing);
    expect(wasShown, isFalse);
  });
}
