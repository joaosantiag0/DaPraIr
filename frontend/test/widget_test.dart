import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('DaPraIrApp smoke test and accessibility rendering', (WidgetTester tester) async {
    await tester.pumpWidget(const DaPraIrApp());

    expect(find.text('DáPraIr?'), findsOneWidget);
    expect(find.text('Bem-vindo ao DáPraIr?'), findsOneWidget);
  });
}
