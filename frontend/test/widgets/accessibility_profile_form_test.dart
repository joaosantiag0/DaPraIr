import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/views/auth/onboarding_accessibility_screen.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/domain/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepo;
  late ProfileBloc profileBloc;

  setUp(() {
    mockRepo = MockUserRepository();
    profileBloc = ProfileBloc(repository: mockRepo);
  });

  tearDown(() {
    profileBloc.close();
  });

  testWidgets('OnboardingAccessibilityScreen displays options and explicit LGPD consent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: profileBloc,
          child: const OnboardingAccessibilityScreen(),
        ),
      ),
    );

    expect(find.text('Personalize sua Experiência'), findsOneWidget);
    expect(find.text('Cadeira de Rodas Manual'), findsOneWidget);
    expect(find.text('Rampa de Acesso Nivelada'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('Salvar e Concluir'), findsOneWidget);
  });
}
