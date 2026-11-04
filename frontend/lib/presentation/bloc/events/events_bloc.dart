import 'package:frontend/core/base/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/repositories/events_repository.dart';

// EVENTS
abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventsRequested extends EventsEvent {
  final String? accessibilityFeature;

  const LoadEventsRequested({this.accessibilityFeature});

  @override
  List<Object?> get props => [accessibilityFeature];
}

class CreateEventRequested extends EventsEvent {
  final String? placeId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String locationName;
  final String address;
  final double? latitude;
  final double? longitude;
  final Map<String, bool> accessibilityChecklist;
  final int? maxAttendees;

  const CreateEventRequested({
    this.placeId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.locationName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.accessibilityChecklist,
    this.maxAttendees,
  });

  @override
  List<Object?> get props => [title, startTime, endTime, accessibilityChecklist];
}

class ToggleRSVPRequested extends EventsEvent {
  final String eventId;
  final bool currentlyAttending;

  const ToggleRSVPRequested({
    required this.eventId,
    required this.currentlyAttending,
  });

  @override
  List<Object?> get props => [eventId, currentlyAttending];
}

// STATES
enum EventsStatus { initial, loading, loaded, creating, created, error }

class EventsState extends Equatable {
  final EventsStatus status;
  final List<EventItem> events;
  final String? selectedFilter;
  final String? errorMessage;
  final EventItem? lastCreatedEvent;

  const EventsState({
    this.status = EventsStatus.initial,
    this.events = const [],
    this.selectedFilter,
    this.errorMessage,
    this.lastCreatedEvent,
  });

  EventsState copyWith({
    EventsStatus? status,
    List<EventItem>? events,
    String? selectedFilter,
    String? errorMessage,
    EventItem? lastCreatedEvent,
  }) {
    return EventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
      lastCreatedEvent: lastCreatedEvent ?? this.lastCreatedEvent,
    );
  }

  @override
  List<Object?> get props => [status, events, selectedFilter, errorMessage, lastCreatedEvent];
}

// BLOC
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventsRepository eventsRepository;

  EventsBloc(this.eventsRepository) : super(const EventsState()) {
    on<LoadEventsRequested>(_onLoadEvents);
    on<CreateEventRequested>(_onCreateEvent);
    on<ToggleRSVPRequested>(_onToggleRSVP);
  }

  Future<void> _onLoadEvents(LoadEventsRequested event, Emitter<EventsState> emit) async {
    emit(state.copyWith(status: EventsStatus.loading, selectedFilter: event.accessibilityFeature));
    try {
      final events = await eventsRepository.getEvents(
        accessibilityFeature: event.accessibilityFeature,
      );
      emit(state.copyWith(status: EventsStatus.loaded, events: events));
    } catch (e) {
      emit(state.copyWith(status: EventsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateEvent(CreateEventRequested event, Emitter<EventsState> emit) async {
    emit(state.copyWith(status: EventsStatus.creating));
    try {
      final newEvent = await eventsRepository.createEvent(
        placeId: event.placeId,
        title: event.title,
        description: event.description,
        startTime: event.startTime,
        endTime: event.endTime,
        locationName: event.locationName,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        accessibilityChecklist: event.accessibilityChecklist,
        maxAttendees: event.maxAttendees,
      );
      final updatedEvents = [newEvent, ...state.events];
      emit(state.copyWith(
        status: EventsStatus.created,
        events: updatedEvents,
        lastCreatedEvent: newEvent,
      ));
    } catch (e) {
      emit(state.copyWith(status: EventsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleRSVP(ToggleRSVPRequested event, Emitter<EventsState> emit) async {
    final newStatus = event.currentlyAttending ? 'DECLINED' : 'CONFIRMED';
    try {
      await eventsRepository.registerRSVP(event.eventId, status: newStatus);
      final updatedEvents = state.events.map((e) {
        if (e.id == event.eventId) {
          final isNowAttending = !event.currentlyAttending;
          final rsvpDelta = isNowAttending ? 1 : -1;
          return EventItem(
            id: e.id,
            title: e.title,
            description: e.description,
            startTime: e.startTime,
            endTime: e.endTime,
            locationName: e.locationName,
            address: e.address,
            latitude: e.latitude,
            longitude: e.longitude,
            accessibilityChecklist: e.accessibilityChecklist,
            maxAttendees: e.maxAttendees,
            status: e.status,
            rsvpCount: (e.rsvpCount + rsvpDelta).clamp(0, 999999),
            isAttending: isNowAttending,
            organizer: e.organizer,
          );
        }
        return e;
      }).toList();

      emit(state.copyWith(events: updatedEvents));
    } catch (e) {
      emit(state.copyWith(status: EventsStatus.error, errorMessage: e.toString()));
    }
  }
}
