import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/storage/user_location_storage.dart';
import 'package:frontend/domain/repositories/places_repository.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/places/places_bloc.dart';
import 'package:frontend/presentation/components/location_selector_sheet.dart';
import 'package:frontend/presentation/views/map_search/map_search_screen.dart';

class MockPlacesBloc extends MockBloc<PlacesEvent, PlacesState> implements PlacesBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockPlacesRepository extends Mock implements PlacesRepository {}

void main() {
  late MockPlacesBloc mockPlacesBloc;
  late MockAuthBloc mockAuthBloc;
  late MockPlacesRepository mockPlacesRepository;

  setUpAll(() {
    registerFallbackValue(const SearchPlacesEvent(latitude: 0, longitude: 0));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockPlacesBloc = MockPlacesBloc();
    mockAuthBloc = MockAuthBloc();
    mockPlacesRepository = MockPlacesRepository();

    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    when(() => mockPlacesBloc.state).thenReturn(PlacesInitial());
    when(() => mockPlacesBloc.add(any())).thenReturn(null);
  });

  testWidgets('MapSearchScreen shows results banner and opens LocationSelectorSheet', (WidgetTester tester) async {
    // Pre-save an encrypted location to verify banner display
    final storage = UserLocationStorage();
    await storage.saveLocation(
      UserSavedLocation(
        label: 'Av. Paulista, 1000',
        address: 'Av. Paulista, 1000',
        city: 'São Paulo',
        state: 'SP',
        latitude: -23.5654,
        longitude: -46.6517,
        isGps: false,
        savedAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PlacesBloc>.value(value: mockPlacesBloc),
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          ],
          child: const MapSearchScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the "Exibindo resultados perto de:" banner
    expect(find.text('Exibindo resultados perto de:'), findsOneWidget);
    expect(find.text('Av. Paulista, 1000'), findsOneWidget);
    expect(find.text('Alterar'), findsOneWidget);

    // Tap "Alterar"
    await tester.tap(find.text('Alterar'));
    await tester.pumpAndSettle();

    // Verify modal options
    expect(find.text('Onde você está?'), findsOneWidget);
    expect(find.text('Usar Localização Atual (GPS)'), findsOneWidget);
    expect(find.text('Digitar Endereço ou Cidade'), findsOneWidget);
  });

  testWidgets('LocationSelectorSheet selecting GPS saves location encrypted', (WidgetTester tester) async {
    UserSavedLocation? selectedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selectedResult = await LocationSelectorSheet.show(
                  context: context,
                  repository: mockPlacesRepository,
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Tap GPS button
    await tester.tap(find.text('Usar Localização Atual (GPS)'));
    await tester.pumpAndSettle();

    // Verify selected result returned and persisted
    expect(selectedResult, isNotNull);
    expect(selectedResult!.isGps, isTrue);

    final saved = await UserLocationStorage().getSavedLocation();
    expect(saved, isNotNull);
    expect(saved!.isGps, isTrue);
  });
}
