import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/domain/entities/accessibility_profile.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';
import 'package:frontend/presentation/views/profile/account_data_governance_screen.dart';
import 'package:frontend/presentation/views/profile/profile_privacy_settings_screen.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockUserRepository mockUserRepo;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockUserRepo = MockUserRepository();
    mockAuthRepo = MockAuthRepository();

    when(() => mockUserRepo.getAccessibilityProfile()).thenAnswer((_) async => const AccessibilityProfile(
      userId: 'u-1',
      disabilityTypes: ['PHYSICAL_WHEELCHAIR'],
      assistanceNeeds: ['RAMP_ACCESS'],
      visibility: 'PRIVATE',
    ));
  });

  Widget createWidgetUnderTest({Widget? child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(create: (_) => ProfileBloc(repository: mockUserRepo)),
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(repository: mockAuthRepo)),
      ],
      child: MaterialApp(
        home: child ?? const ProfilePrivacySettingsScreen(isAuthenticated: true),
      ),
    );
  }

  testWidgets('navigates from ProfilePrivacySettingsScreen to AccountDataGovernanceScreen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify link to second screen is visible on main profile screen
    expect(find.text('Gerenciamento de Dados e Conta'), findsOneWidget);
    expect(find.text('Portabilidade de dados e exclusão de conta'), findsOneWidget);

    // Verify direct danger and export buttons are NOT on the main profile screen
    expect(find.text('Exportar Meus Dados em JSON'), findsNothing);
    expect(find.text('Anonimizar e Excluir Minha Conta'), findsNothing);

    // Tap to open secondary screen
    await tester.tap(find.text('Gerenciamento de Dados e Conta'));
    await tester.pumpAndSettle();

    // Verify secondary screen is displayed with portability and right to be forgotten
    expect(find.text('Gestão de Dados e Conta'), findsOneWidget);
    expect(find.text('Portabilidade de Dados (Art. 18, V)'), findsOneWidget);
    expect(find.text('Direito ao Esquecimento (Art. 18, VI)'), findsOneWidget);
    expect(find.text('Exportar Meus Dados em JSON'), findsOneWidget);
    expect(find.text('Anonimizar e Excluir Minha Conta'), findsOneWidget);
  });

  testWidgets('AccountDataGovernanceScreen renders portability and danger zone actions', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(child: const AccountDataGovernanceScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Portabilidade de Dados (Art. 18, V)'), findsOneWidget);
    expect(find.text('Direito ao Esquecimento (Art. 18, VI)'), findsOneWidget);

    // Tap delete button to open confirmation dialog
    await tester.tap(find.text('Anonimizar e Excluir Minha Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar Exclusão e Anonimização?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });
}
