import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/components/accessible_button.dart';
import 'package:frontend/presentation/components/accessible_text_field.dart';
import 'package:frontend/presentation/components/accessible_card.dart';

void main() {
  group('WCAG 2.1 AA / AAA Accessibility Audit', () {
    testWidgets('AccessibleButton meets tap target and labeled guidelines', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AccessibleButton(
                label: 'Confirmar Presença',
                semanticHint: 'Toque duas vezes para confirmar presença no evento',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify guidelines
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      // Verify touch target >= 48x48
      final buttonSize = tester.getSize(find.byType(AccessibleButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));

      handle.dispose();
    });

    testWidgets('AccessibleTextField meets tap target and semantics guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AccessibleTextField(
                  controller: controller,
                  label: 'Nome de Usuário',
                  hint: 'Digite seu nome',
                ),
              ),
            ),
          ),
        ),
      );

      // Verify minimum touch height
      final fieldSize = tester.getSize(find.byType(AccessibleTextField));
      expect(fieldSize.height, greaterThanOrEqualTo(48.0));

      // Verify semantics
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.textField == true && w.properties.label == 'Nome de Usuário',
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('AccessibleCard provides proper semantics label and role', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AccessibleCard(
                semanticLabel: 'Restaurante Acessível, Nota 4.8, 12 avaliações',
                onTap: () {},
                child: const Text('Restaurante Acessível'),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Restaurante Acessível, Nota 4.8, 12 avaliações' &&
              w.properties.button == true,
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('High Contrast Theme applies strong contrast colors', (tester) async {
      final theme = AppTheme.highContrastTheme;
      expect(theme.scaffoldBackgroundColor, Colors.black);
      expect(theme.colorScheme.onSurface, Colors.white);
      expect(theme.textTheme.bodyLarge?.color, Colors.white);
    });
  });
}
