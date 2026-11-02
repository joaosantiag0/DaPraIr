import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/views/place/submit_review_screen.dart';
import 'package:frontend/presentation/bloc/reviews/reviews_bloc.dart';
import 'package:frontend/domain/repositories/places_repository.dart';

class MockPlacesRepository extends Mock implements PlacesRepository {}

void main() {
  late MockPlacesRepository mockRepo;
  late ReviewsBloc reviewsBloc;

  setUp(() {
    mockRepo = MockPlacesRepository();
    when(() => mockRepo.getReviewDraft(any())).thenAnswer((_) async => null);
    when(() => mockRepo.getPlaceReviews(any(), limit: any(named: 'limit'), offset: any(named: 'offset')))
        .thenAnswer((_) async => []);
    reviewsBloc = ReviewsBloc(repository: mockRepo);
  });

  tearDown(() {
    reviewsBloc.close();
  });

  testWidgets('SubmitReviewScreen renders 7 criteria and accessible controls', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: reviewsBloc,
          child: const SubmitReviewScreen(placeId: 'place-123'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notas de Acessibilidade (1 a 5)'), findsOneWidget);
    expect(find.text('Entrada com Rampa ou Nivelada'), findsOneWidget);
    expect(find.text('Elevador ou Plataforma Elevatória'), findsOneWidget);
    expect(find.text('Banheiro Adaptado'), findsOneWidget);
    expect(find.text('Espaço de Circulação e Manobra'), findsOneWidget);
    expect(find.text('Assentos e Mesas Acessíveis'), findsOneWidget);
    expect(find.text('Vagas Reservadas'), findsOneWidget);
    expect(find.text('Atendimento Inclusivo'), findsOneWidget);
    expect(find.text('Publicar Avaliação'), findsOneWidget);
  });
}
