import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/repositories/places_repository.dart';

// Events
abstract class PlacesEvent extends Equatable {
  const PlacesEvent();
  @override
  List<Object?> get props => [];
}

class SearchPlacesEvent extends PlacesEvent {
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String? query;
  final String? category;
  final List<String> requiredCriteria;

  const SearchPlacesEvent({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 5000,
    this.query,
    this.category,
    this.requiredCriteria = const [],
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusMeters, query, category, requiredCriteria];
}

class LoadPlaceDetailsEvent extends PlacesEvent {
  final String placeId;
  const LoadPlaceDetailsEvent(this.placeId);
  @override
  List<Object?> get props => [placeId];
}

class CreatePlaceEvent extends PlacesEvent {
  final String name;
  final String? description;
  final String category;
  final String address;
  final String city;
  final String state;
  final String? postalCode;
  final double latitude;
  final double longitude;
  final String? googlePlaceId;

  const CreatePlaceEvent({
    required this.name,
    this.description,
    required this.category,
    required this.address,
    required this.city,
    required this.state,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    this.googlePlaceId,
  });

  @override
  List<Object?> get props => [name, category, address, latitude, longitude, postalCode];
}

// States
abstract class PlacesState extends Equatable {
  const PlacesState();
  @override
  List<Object?> get props => [];
}

class PlacesInitial extends PlacesState {}
class PlacesLoading extends PlacesState {}

class PlacesLoaded extends PlacesState {
  final List<Place> places;
  final Place? selectedPlace;
  final List<String> activeFilters;

  const PlacesLoaded({
    required this.places,
    this.selectedPlace,
    this.activeFilters = const [],
  });

  PlacesLoaded copyWith({
    List<Place>? places,
    Place? selectedPlace,
    List<String>? activeFilters,
  }) {
    return PlacesLoaded(
      places: places ?? this.places,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }

  @override
  List<Object?> get props => [places, selectedPlace, activeFilters];
}

class PlacesError extends PlacesState {
  final String message;
  const PlacesError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final PlacesRepository repository;

  PlacesBloc({required this.repository}) : super(PlacesInitial()) {
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<LoadPlaceDetailsEvent>(_onLoadPlaceDetails);
    on<CreatePlaceEvent>(_onCreatePlace);
  }

  Future<void> _onSearchPlaces(SearchPlacesEvent event, Emitter<PlacesState> emit) async {
    emit(PlacesLoading());
    try {
      final places = await repository.searchPlaces(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusMeters: event.radiusMeters,
        query: event.query,
        category: event.category,
        requiredCriteria: event.requiredCriteria,
      );
      emit(PlacesLoaded(places: places, activeFilters: event.requiredCriteria));
    } catch (e) {
      emit(PlacesError(e.toString()));
    }
  }

  Future<void> _onLoadPlaceDetails(LoadPlaceDetailsEvent event, Emitter<PlacesState> emit) async {
    try {
      final place = await repository.getPlaceDetails(event.placeId);
      if (state is PlacesLoaded) {
        emit((state as PlacesLoaded).copyWith(selectedPlace: place));
      } else {
        emit(PlacesLoaded(places: [place], selectedPlace: place));
      }
    } catch (e) {
      emit(PlacesError(e.toString()));
    }
  }

  Future<void> _onCreatePlace(CreatePlaceEvent event, Emitter<PlacesState> emit) async {
    emit(PlacesLoading());
    try {
      final created = await repository.createPlace(
        name: event.name,
        description: event.description,
        category: event.category,
        address: event.address,
        city: event.city,
        state: event.state,
        postalCode: event.postalCode,
        latitude: event.latitude,
        longitude: event.longitude,
        googlePlaceId: event.googlePlaceId,
      );
      emit(PlacesLoaded(places: [created], selectedPlace: created));
    } catch (e) {
      emit(PlacesError(e.toString()));
    }
  }
}
