import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/entities/place.dart';
import 'package:frontend/domain/entities/review.dart';
import 'package:frontend/domain/repositories/places_repository.dart';
import 'package:frontend/presentation/bloc/reviews/reviews_bloc.dart';

class MockPlacesRepository extends Mock implements PlacesRepository {}

void main() {
  late MockPlacesRepository mockRepo;
  late ReviewsBloc reviewsBloc;

  final sampleReview = Review(
    id: 'rev-1',
    placeId: 'place-1',
    author: const ReviewAuthor(id: 'u1', name: 'João', handle: '@joao'),
    ratings: const [
      ReviewRatingItem(criterionCode: 'ENTRANCE_RAMP_LEVEL', criterionTitle: 'Rampa', score: 5),
    ],
    averageScore: 5.0,
    generalComment: 'Excelente rampa e portas largas!',
    media: const [
      PlaceMediaItem(
        id: 'media-1',
        mediaUrl: 'https://example.com/photo.jpg',
        thumbnailUrl: 'https://example.com/photo_thumb.jpg',
        altText: 'Rampa de acesso suave com corrimão duplo',
      ),
    ],
    reportCount: 0,
    status: 'PUBLISHED',
    createdAt: DateTime(2026, 11, 1),
  );

  setUp(() {
    mockRepo = MockPlacesRepository();
    reviewsBloc = ReviewsBloc(repository: mockRepo);
  });

  tearDown(() {
    reviewsBloc.close();
  });

  group('ReviewsBloc', () {
    test('initial state is ReviewsInitial', () {
      expect(reviewsBloc.state, isA<ReviewsInitial>());
    });

    blocTest<ReviewsBloc, ReviewsState>(
      'SubmitReviewEvent without photo submits review directly',
      build: () {
        when(() => mockRepo.submitReview(
              placeId: 'place-1',
              generalComment: 'Muito bom',
              ratings: any(named: 'ratings'),
              mediaIds: null,
            )).thenAnswer((_) async => sampleReview);
        when(() => mockRepo.getPlaceReviews('place-1')).thenAnswer((_) async => [sampleReview]);
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const SubmitReviewEvent(
        placeId: 'place-1',
        generalComment: 'Muito bom',
        ratings: [{'criterionCode': 'ENTRANCE_RAMP_LEVEL', 'score': 5}],
      )),
      expect: () => [
        isA<ReviewsLoading>(),
        isA<ReviewsLoaded>()
            .having((s) => s.submitSuccess, 'submitSuccess', true)
            .having((s) => s.reviews.length, 'reviews length', 1),
      ],
      verify: (_) {
        verifyNever(() => mockRepo.uploadPhoto(
              placeId: any(named: 'placeId'),
              altText: any(named: 'altText'),
              bytes: any(named: 'bytes'),
              fileName: any(named: 'fileName'),
            ));
        verify(() => mockRepo.submitReview(
              placeId: 'place-1',
              generalComment: 'Muito bom',
              ratings: any(named: 'ratings'),
              mediaIds: null,
            )).called(1);
      },
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'SubmitReviewEvent with photo uploads photo first and links mediaIds',
      build: () {
        when(() => mockRepo.uploadPhoto(
              placeId: 'place-1',
              altText: 'Rampa acessível com piso tátil',
              bytes: any(named: 'bytes'),
              fileName: 'rampa.jpg',
            )).thenAnswer((_) async => 'media-uploaded-123');
        when(() => mockRepo.submitReview(
              placeId: 'place-1',
              generalComment: 'Ótima rampa',
              ratings: any(named: 'ratings'),
              mediaIds: ['media-uploaded-123'],
            )).thenAnswer((_) async => sampleReview);
        when(() => mockRepo.getPlaceReviews('place-1')).thenAnswer((_) async => [sampleReview]);
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(SubmitReviewEvent(
        placeId: 'place-1',
        generalComment: 'Ótima rampa',
        ratings: const [{'criterionCode': 'ENTRANCE_RAMP_LEVEL', 'score': 5}],
        photoBytes: Uint8List.fromList([1, 2, 3, 4]),
        photoAltText: 'Rampa acessível com piso tátil',
        photoFileName: 'rampa.jpg',
      )),
      expect: () => [
        isA<ReviewsLoading>(),
        isA<ReviewsLoaded>()
            .having((s) => s.submitSuccess, 'submitSuccess', true)
            .having((s) => s.reviews.first.media.length, 'media count', 1),
      ],
      verify: (_) {
        verify(() => mockRepo.uploadPhoto(
              placeId: 'place-1',
              altText: 'Rampa acessível com piso tátil',
              bytes: any(named: 'bytes'),
              fileName: 'rampa.jpg',
            )).called(1);
        verify(() => mockRepo.submitReview(
              placeId: 'place-1',
              generalComment: 'Ótima rampa',
              ratings: any(named: 'ratings'),
              mediaIds: ['media-uploaded-123'],
            )).called(1);
      },
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'SaveReviewDraftEvent saves draft offline with photos',
      build: () {
        when(() => mockRepo.saveReviewDraft(
              placeId: 'place-1',
              generalComment: 'Rascunho de nota',
              ratings: {'ENTRANCE_RAMP_LEVEL': 5},
              photos: any(named: 'photos'),
            )).thenAnswer((_) async {});
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const SaveReviewDraftEvent(
        placeId: 'place-1',
        generalComment: 'Rascunho de nota',
        ratings: {'ENTRANCE_RAMP_LEVEL': 5},
        photos: [{'altText': 'Entrada principal'}],
      )),
      verify: (_) {
        verify(() => mockRepo.saveReviewDraft(
              placeId: 'place-1',
              generalComment: 'Rascunho de nota',
              ratings: {'ENTRANCE_RAMP_LEVEL': 5},
              photos: any(named: 'photos'),
            )).called(1);
      },
    );
  });
}
