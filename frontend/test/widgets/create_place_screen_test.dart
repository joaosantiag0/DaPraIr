import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/entities/place.dart';
import 'package:frontend/domain/repositories/places_repository.dart';
import 'package:frontend/presentation/bloc/places/places_bloc.dart';
import 'package:frontend/presentation/views/place/create_place_screen.dart';

class MockPlacesRepository extends Mock implements PlacesRepository {}

void main() {
  late MockPlacesRepository mockPlacesRepo;
  late PlacesBloc placesBloc;

  setUp(() {
    mockPlacesRepo = MockPlacesRepository();
    placesBloc = PlacesBloc(repository: mockPlacesRepo);

    when(() => mockPlacesRepo.searchExternalPlaces(
          query: any(named: 'query'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => const [
          ExternalPlaceSuggestion(
            googlePlaceId: 'google-p-1',
            name: 'Café Inclusivo Paulista',
            formattedAddress: 'Av. Paulista, 1000 - Bela Vista',
            latitude: -23.565,
            longitude: -46.651,
            category: 'Café',
          ),
        ]);
  });

  tearDown(() {
    placesBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlacesBloc>.value(value: placesBloc),
      ],
      child: MaterialApp(
        home: CreatePlaceScreen(placesRepository: mockPlacesRepo),
      ),
    );
  }

  testWidgets('CreatePlaceScreen shows nearby Google Places and creates place on click', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Screen title and nearby establishments
    expect(find.text('Adicionar Novo Local'), findsOneWidget);
    expect(find.text('Café Inclusivo Paulista'), findsOneWidget);
    expect(find.text('Av. Paulista, 1000 - Bela Vista'), findsOneWidget);
    expect(find.text('Avaliar'), findsOneWidget);

    // Setup mock for creation with googlePlaceId
    when(() => mockPlacesRepo.createPlace(
          name: 'Café Inclusivo Paulista',
          description: any(named: 'description'),
          category: any(named: 'category'),
          address: 'Av. Paulista, 1000 - Bela Vista',
          city: 'São Paulo',
          state: 'SP',
          postalCode: any(named: 'postalCode'),
          latitude: -23.565,
          longitude: -46.651,
          googlePlaceId: 'google-p-1',
        )).thenAnswer((_) async => const Place(
          id: 'place-google-1',
          name: 'Café Inclusivo Paulista',
          category: 'Café',
          address: 'Av. Paulista, 1000 - Bela Vista',
          city: 'São Paulo',
          state: 'SP',
          latitude: -23.565,
          longitude: -46.651,
          overallScore: 0.0,
          totalReviews: 0,
          source: 'GOOGLE_PLACES',
        ));

    // Tap "Avaliar" button on Google Place item
    await tester.tap(find.text('Avaliar'));
    await tester.pump();

    verify(() => mockPlacesRepo.createPlace(
          name: 'Café Inclusivo Paulista',
          description: any(named: 'description'),
          category: any(named: 'category'),
          address: 'Av. Paulista, 1000 - Bela Vista',
          city: 'São Paulo',
          state: 'SP',
          postalCode: any(named: 'postalCode'),
          latitude: -23.565,
          longitude: -46.651,
          googlePlaceId: 'google-p-1',
        )).called(1);
  });

  testWidgets('CreatePlaceScreen triggers search with debounce or explicit search button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Type query and wait for debounce timeout
    await tester.enterText(find.byType(TextField), 'Restaurante Acessível');
    await tester.pump(const Duration(milliseconds: 800));

    verify(() => mockPlacesRepo.searchExternalPlaces(
          query: 'Restaurante Acessível',
          latitude: null,
          longitude: null,
        )).called(1);

    // Wait for first search to settle
    await tester.pumpAndSettle();

    // Explicit search button tap
    await tester.tap(find.byKey(const Key('btn_search_places')));
    await tester.pumpAndSettle();

    verify(() => mockPlacesRepo.searchExternalPlaces(
          query: 'Restaurante Acessível',
          latitude: null,
          longitude: null,
        )).called(1);
  });

  testWidgets('CreatePlaceScreen only shows manual form when tapping "Cadastrar Local Manualmente"', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Manual form fields should NOT be visible initially
    expect(find.text('Nome do Estabelecimento *'), findsNothing);
    expect(find.byKey(const Key('btn_open_manual_form')), findsOneWidget);

    // Open manual form
    final openManualBtn = find.byKey(const Key('btn_open_manual_form'));
    await tester.ensureVisible(openManualBtn);
    await tester.tap(openManualBtn);
    await tester.pumpAndSettle();

    // Now manual form is visible
    expect(find.text('Cadastrar Manualmente'), findsOneWidget);
    expect(find.text('Nome do Estabelecimento *'), findsOneWidget);
    expect(find.text('Categoria *'), findsOneWidget);
    expect(find.text('Endereço Completo *'), findsOneWidget);
    expect(find.text('Cidade *'), findsOneWidget);
    expect(find.text('UF *'), findsOneWidget);
    expect(find.text('Cadastrar Local'), findsOneWidget);

    // Try submitting empty name
    final submitBtn = find.text('Cadastrar Local');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();
    expect(find.text('O nome do local deve conter pelo menos 2 caracteres.'), findsOneWidget);

    // Fill valid info
    await tester.enterText(
      find.widgetWithText(TextFormField, '').first,
      'Padaria Inclusiva',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Rua Bela Cintra, 500',
    );

    when(() => mockPlacesRepo.createPlace(
          name: any(named: 'name'),
          description: any(named: 'description'),
          category: any(named: 'category'),
          address: any(named: 'address'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          postalCode: any(named: 'postalCode'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => const Place(
          id: 'place-new-1',
          name: 'Padaria Inclusiva',
          category: 'Restaurante',
          address: 'Rua Bela Cintra, 500',
          city: 'São Paulo',
          state: 'SP',
          latitude: -23.55052,
          longitude: -46.633308,
          overallScore: 0.0,
          totalReviews: 0,
        ));

    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();

    verify(() => mockPlacesRepo.createPlace(
          name: 'Padaria Inclusiva',
          description: any(named: 'description'),
          category: 'Restaurante',
          address: 'Rua Bela Cintra, 500',
          city: 'São Paulo',
          state: 'SP',
          postalCode: any(named: 'postalCode'),
          latitude: -23.55052,
          longitude: -46.633308,
        )).called(1);
  });
}
