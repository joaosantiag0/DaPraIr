import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/bloc/places/places_bloc.dart';
import 'package:frontend/domain/entities/place.dart';
import 'package:frontend/domain/repositories/places_repository.dart';

class MockPlacesRepository extends Mock implements PlacesRepository {}

void main() {
  late MockPlacesRepository mockRepo;

  const testPlace = Place(
    id: 'p-1',
    name: 'Restaurante Central',
    category: 'RESTAURANT',
    address: 'Av Paulista, 100',
    city: 'São Paulo',
    state: 'SP',
    latitude: -23.56,
    longitude: -46.65,
    overallScore: 4.8,
    totalReviews: 5,
  );

  setUp(() {
    mockRepo = MockPlacesRepository();
  });

  blocTest<PlacesBloc, PlacesState>(
    'emits [PlacesLoading, PlacesLoaded] on SearchPlacesEvent',
    build: () {
      when(
        () => mockRepo.searchPlaces(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radiusMeters: any(named: 'radiusMeters'),
          query: any(named: 'query'),
          category: any(named: 'category'),
          requiredCriteria: any(named: 'requiredCriteria'),
        ),
      ).thenAnswer((_) async => [testPlace]);
      return PlacesBloc(repository: mockRepo);
    },
    act: (bloc) => bloc.add(const SearchPlacesEvent(latitude: -23.56, longitude: -46.65)),
    expect: () => [
      PlacesLoading(),
      const PlacesLoaded(places: [testPlace]),
    ],
  );

  blocTest<PlacesBloc, PlacesState>(
    'emits [PlacesLoaded] on LoadPlaceDetailsEvent',
    build: () {
      when(() => mockRepo.getPlaceDetails('p-1')).thenAnswer((_) async => testPlace);
      return PlacesBloc(repository: mockRepo);
    },
    act: (bloc) => bloc.add(const LoadPlaceDetailsEvent('p-1')),
    expect: () => [
      const PlacesLoaded(places: [testPlace], selectedPlace: testPlace),
    ],
  );
}
