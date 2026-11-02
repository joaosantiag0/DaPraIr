import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/repositories/events_repository.dart';
import 'package:frontend/presentation/bloc/events/events_bloc.dart';

class MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  late MockEventsRepository mockRepository;
  late EventsBloc eventsBloc;

  final sampleEvent = EventItem(
    id: 'e1',
    title: 'Show Inclusivo',
    description: 'Show com interpretação em Libras',
    startTime: DateTime(2026, 12, 1, 19, 0),
    endTime: DateTime(2026, 12, 1, 22, 0),
    locationName: 'Teatro Municipal',
    address: 'Praça Ramos de Azevedo, s/n',
    accessibilityChecklist: const {'interprete_libras': true},
    status: 'SCHEDULED',
    rsvpCount: 15,
    isAttending: false,
    organizer: const EventOrganizer(id: 'u1', name: 'Ana', handle: 'ana'),
  );

  setUp(() {
    mockRepository = MockEventsRepository();
    eventsBloc = EventsBloc(mockRepository);
  });

  tearDown(() {
    eventsBloc.close();
  });

  test('LoadEventsRequested emits [loading, loaded] on success', () async {
    when(() => mockRepository.getEvents(accessibilityFeature: any(named: 'accessibilityFeature')))
        .thenAnswer((_) async => [sampleEvent]);

    expectLater(
      eventsBloc.stream,
      emitsInOrder([
        const EventsState(status: EventsStatus.loading, selectedFilter: null),
        EventsState(status: EventsStatus.loaded, events: [sampleEvent]),
      ]),
    );

    eventsBloc.add(const LoadEventsRequested());
  });

  test('CreateEventRequested emits [creating, created] with new event', () async {
    when(() => mockRepository.createEvent(
          placeId: any(named: 'placeId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          locationName: any(named: 'locationName'),
          address: any(named: 'address'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          accessibilityChecklist: any(named: 'accessibilityChecklist'),
          maxAttendees: any(named: 'maxAttendees'),
        )).thenAnswer((_) async => sampleEvent);

    expectLater(
      eventsBloc.stream,
      emitsInOrder([
        const EventsState(status: EventsStatus.creating),
        EventsState(
          status: EventsStatus.created,
          events: [sampleEvent],
          lastCreatedEvent: sampleEvent,
        ),
      ]),
    );

    eventsBloc.add(CreateEventRequested(
      title: sampleEvent.title,
      description: sampleEvent.description,
      startTime: sampleEvent.startTime,
      endTime: sampleEvent.endTime,
      locationName: sampleEvent.locationName,
      address: sampleEvent.address,
      accessibilityChecklist: sampleEvent.accessibilityChecklist,
    ));
  });

  test('ToggleRSVPRequested updates RSVP count and attendance', () async {
    when(() => mockRepository.registerRSVP(any(), status: any(named: 'status')))
        .thenAnswer((_) async {});

    eventsBloc.emit(EventsState(status: EventsStatus.loaded, events: [sampleEvent]));

    eventsBloc.add(ToggleRSVPRequested(eventId: sampleEvent.id, currentlyAttending: false));

    await expectLater(
      eventsBloc.stream,
      emits(predicate<EventsState>((state) {
        final ev = state.events.first;
        return ev.isAttending == true && ev.rsvpCount == 16;
      })),
    );
  });
}
