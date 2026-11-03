import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/bloc/social/social_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/domain/entities/social_connection.dart';
import 'package:frontend/domain/repositories/social_repository.dart';
import 'package:frontend/presentation/views/social/social_connections_screen.dart';

class MockSocialRepository extends Mock implements SocialRepository {}

void main() {
  late MockSocialRepository mockSocialRepo;

  setUp(() {
    mockSocialRepo = MockSocialRepository();
  });

  Widget createWidgetUnderTest({required bool isAuthenticated, VoidCallback? onNavigateToLogin}) {
    return MaterialApp(
      home: BlocProvider<SocialBloc>(
        create: (_) => SocialBloc(repository: mockSocialRepo),
        child: SocialConnectionsScreen(
          isAuthenticated: isAuthenticated,
          onNavigateToLogin: onNavigateToLogin,
        ),
      ),
    );
  }

  testWidgets('renders friendly guest view when user is unauthenticated', (tester) async {
    bool loginPressed = false;

    await tester.pumpWidget(
      createWidgetUnderTest(
        isAuthenticated: false,
        onNavigateToLogin: () => loginPressed = true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Conecte-se com a Comunidade'), findsOneWidget);
    expect(find.text('Entrar ou Cadastrar'), findsOneWidget);
    expect(find.text('Amigos'), findsNothing); // TabBar should not be present in guest mode

    await tester.tap(find.text('Entrar ou Cadastrar'));
    await tester.pumpAndSettle();

    expect(loginPressed, isTrue);
    verifyNever(() => mockSocialRepo.getConnections());
  });

  testWidgets('loads and displays tabs when user is authenticated', (tester) async {
    when(() => mockSocialRepo.getConnections()).thenAnswer((_) async => []);
    when(() => mockSocialRepo.getRecommendations()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      createWidgetUnderTest(isAuthenticated: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amigos'), findsOneWidget);
    expect(find.text('Solicitações'), findsOneWidget);
    expect(find.text('Sugestões'), findsOneWidget);
    expect(find.text('Você ainda não tem amigos conectados.'), findsOneWidget);

    verify(() => mockSocialRepo.getConnections()).called(1);
    verify(() => mockSocialRepo.getRecommendations()).called(1);
  });
}
