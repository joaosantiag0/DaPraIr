import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/entities/place.dart';
import 'package:frontend/domain/entities/user_profile.dart';
import 'package:frontend/domain/repositories/places_repository.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';
import 'package:frontend/presentation/bloc/places/places_bloc.dart';
import 'package:frontend/presentation/bloc/reviews/reviews_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/views/place/place_detail_screen.dart';
import 'package:frontend/presentation/views/place/submit_review_screen.dart';
import 'package:frontend/presentation/components/guest_action_dialog.dart';

class MockPlacesRepository extends Mock implements PlacesRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockPlacesRepository mockPlacesRepo;
  late MockAuthRepository mockAuthRepo;
  late PlacesBloc placesBloc;
  late ReviewsBloc reviewsBloc;
  late AuthBloc authBloc;

  final samplePlace = Place(
    id: 'place-abc',
    name: 'Restaurante Central',
    category: 'Restaurante',
    address: 'Rua das Flores, 100',
    city: 'São Paulo',
    state: 'SP',
    latitude: -23.55052,
    longitude: -46.633308,
    overallScore: 4.8,
    totalReviews: 12,
    criteriaBreakdown: const [],
  );

  final testUser = const UserProfile(
    id: 'user-1',
    name: 'Ana Silva',
    email: 'ana@example.com',
    handle: '@ana',
  );

  setUp(() {
    mockPlacesRepo = MockPlacesRepository();
    mockAuthRepo = MockAuthRepository();

    when(() => mockPlacesRepo.getPlaceDetails('place-abc')).thenAnswer((_) async => samplePlace);
    when(() => mockPlacesRepo.getPlaceReviews('place-abc')).thenAnswer((_) async => []);
    when(() => mockPlacesRepo.getReviewDraft(any())).thenAnswer((_) async => null);

    placesBloc = PlacesBloc(repository: mockPlacesRepo);
    reviewsBloc = ReviewsBloc(repository: mockPlacesRepo);
    authBloc = AuthBloc(repository: mockAuthRepo);
  });

  tearDown(() {
    placesBloc.close();
    reviewsBloc.close();
    authBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlacesBloc>.value(value: placesBloc),
        BlocProvider<ReviewsBloc>.value(value: reviewsBloc),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: MaterialApp(
        home: PlaceDetailScreen(
          placeId: 'place-abc',
          initialPlace: samplePlace,
        ),
      ),
    );
  }

  testWidgets('Prompts GuestActionDialog when unauthenticated, and opens review when authenticated',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 1. Initially unauthenticated, tap 'Avaliar Local'
    final evaluateButton = find.text('Avaliar Local');
    expect(evaluateButton, findsOneWidget);
    await tester.tap(evaluateButton);
    await tester.pumpAndSettle();

    // Expect GuestActionDialog
    expect(find.byType(GuestActionDialog), findsOneWidget);
    expect(find.text('Entrar no DáPraIr?'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Continuar Visitando'));
    await tester.pumpAndSettle();
    expect(find.byType(GuestActionDialog), findsNothing);

    // 2. User logs in (AuthBloc state becomes Authenticated)
    authBloc.emit(Authenticated(testUser));
    await tester.pump();

    // 3. User taps 'Avaliar Local' again
    await tester.tap(evaluateButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Should NOT show dialog again, but navigate straight to SubmitReviewScreen
    expect(find.byType(GuestActionDialog), findsNothing);
    expect(find.byType(SubmitReviewScreen), findsOneWidget);
    expect(find.text('Enviar Avaliação'), findsOneWidget);
  });
}
