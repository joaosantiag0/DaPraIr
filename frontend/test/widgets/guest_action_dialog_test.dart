import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/components/guest_action_dialog.dart';

void main() {
  testWidgets('GuestActionDialog renders correctly with semantics and handles login tap', (tester) async {
    final handle = tester.ensureSemantics();
    bool loginPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                GuestActionDialog.show(
                  context: context,
                  actionTitle: 'avaliar as condições deste local',
                  onLoginPressed: () {
                    loginPressed = true;
                  },
                );
              },
              child: const Text('Disparar Ação Convidado'),
            ),
          ),
        ),
      ),
    );

    // Tap button to open dialog
    await tester.tap(find.text('Disparar Ação Convidado'));
    await tester.pumpAndSettle();

    // Verify dialog contents
    expect(find.text('Entrar no DáPraIr?'), findsOneWidget);
    expect(find.text('Você está no Modo Convidado.'), findsOneWidget);
    expect(find.text('Fazer Login'), findsOneWidget);
    expect(find.text('Continuar Visitando'), findsOneWidget);

    // Tap 'Fazer Login'
    await tester.tap(find.text('Fazer Login'));
    await tester.pumpAndSettle();

    expect(loginPressed, isTrue);

    handle.dispose();
  });
}
