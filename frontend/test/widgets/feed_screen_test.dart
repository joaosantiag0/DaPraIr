import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/presentation/views/home/feed_screen.dart';
import 'package:frontend/presentation/bloc/feed/feed_bloc.dart';
import 'package:frontend/domain/entities/feed_item.dart';

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

void main() {
  late MockFeedBloc mockFeedBloc;

  setUp(() {
    mockFeedBloc = MockFeedBloc();
  });

  final sampleFeedData = FeedData(
    highlightedPlaces: const [
      HighlightedPlace(
        id: 'place-1',
        name: 'Museu da Inclusão',
        category: 'MUSEUM',
        address: 'Av. Paulista, 1000',
        latitude: -23.56,
        longitude: -46.65,
        overallScore: 4.8,
        totalReviews: 24,
      ),
    ],
    recentReviews: [
      RecentFeedReview(
        id: 'rev-1',
        placeId: 'place-1',
        placeName: 'Museu da Inclusão',
        placeAddress: 'Av. Paulista, 1000',
        generalComment: 'Excelente rampa e guias atenciosos!',
        averageScore: 5.0,
        status: 'UNDER_REVIEW',
        createdAt: DateTime(2026, 11, 1),
        authorName: 'Carlos Silva',
        authorHandle: '@carlos_s',
        mediaThumbnails: const [],
      ),
    ],
    upcomingEvents: [
      FeedEventSummary(
        id: 'ev-1',
        title: 'Sarau com Acessibilidade',
        description: 'Música e poesia com audiodescrição',
        startTime: DateTime(2026, 12, 1, 18, 0),
        endTime: DateTime(2026, 12, 1, 21, 0),
        locationName: 'Centro Cultural São Paulo',
        address: 'Rua Vergueiro, 1000',
        rsvpCount: 12,
        isAttending: false,
        organizerName: 'Ana Rosa',
      ),
    ],
    accessibilityTips: const [
      AccessibilityTip(
        id: 'tip-1',
        title: 'Inclinação de Rampas',
        content: 'Inclinação máxima recomendada é de 8,33%.',
        category: 'MOBILITY',
      ),
    ],
  );

  testWidgets('FeedScreen displays sections, highlighted places and under_review badge', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockFeedBloc.state).thenReturn(
      FeedState(status: FeedStatus.loaded, feedData: sampleFeedData),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FeedBloc>.value(
          value: mockFeedBloc,
          child: const FeedScreen(),
        ),
      ),
    );

    // Verify sections
    expect(find.text('Locais Acessíveis em Destaque'), findsOneWidget);
    expect(find.text('Museu da Inclusão'), findsWidgets);
    expect(find.text('Próximos Eventos Inclusivos'), findsOneWidget);
    expect(find.text('Sarau com Acessibilidade'), findsOneWidget);
    expect(find.text('Últimas Avaliações da Comunidade'), findsOneWidget);
    expect(find.text('Excelente rampa e guias atenciosos!'), findsOneWidget);

    // Verify under review badge for reported review
    expect(find.text('Sob análise da moderação'), findsOneWidget);

    // Verify tips
    expect(find.text('Dicas de Acessibilidade & Normas'), findsOneWidget);
    expect(find.text('Inclinação de Rampas'), findsOneWidget);
  });
}
