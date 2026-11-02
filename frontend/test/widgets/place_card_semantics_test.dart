import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/components/accessible_button.dart';
import 'package:frontend/presentation/components/accessible_card.dart';

void main() {
  testWidgets('AccessibleButton adheres to >= 48x48 dp touch target and semantics', (tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AccessibleButton(
              label: 'Avaliar Local',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      ),
    );

    // Verify touch target >= 48 dp
    final buttonSize = tester.getSize(find.byType(AccessibleButton));
    expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    expect(buttonSize.width, greaterThanOrEqualTo(48.0));

    // Verify semantics
    expect(
      tester.getSemantics(find.byType(AccessibleButton)),
      matchesSemantics(
        isButton: true,
        isEnabled: true,
        label: 'Avaliar Local',
        hasEnabledState: true,
      ),
    );

    // Tap button
    await tester.tap(find.byType(AccessibleButton));
    expect(pressed, true);
  });

  testWidgets('AccessibleCard has semantic container and accessible tap area', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AccessibleCard(
              semanticLabel: 'Restaurante Acessível Centro, Nota 4.5 de 5 estrelas',
              onTap: () {
                tapped = true;
              },
              child: const Text('Conteúdo do Card'),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(AccessibleCard)),
      matchesSemantics(
        label: 'Restaurante Acessível Centro, Nota 4.5 de 5 estrelas',
        isButton: true,
      ),
    );

    await tester.tap(find.byType(AccessibleCard));
    expect(tapped, true);
  });
}
