import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/presentation/views/events/events_list_screen.dart';

void main() {
  testWidgets('EventCard exposes correct accessibility semantics and touch target', (tester) async {
    final event = EventItem(
      id: 'event-1',
      title: 'Passeio Acessível Parque Villa-Lobos',
      description: 'Passeio em grupo adaptado para cadeirantes e cegos',
      startTime: DateTime(2026, 12, 1, 10, 0),
      endTime: DateTime(2026, 12, 1, 13, 0),
      locationName: 'Parque Villa-Lobos',
      address: 'Av. Prof. Fonseca Rodrigues, 2001',
      accessibilityChecklist: const {
        'rampa_acesso': true,
        'banheiro_adaptado': true,
      },
      status: 'SCHEDULED',
      rsvpCount: 8,
      isAttending: false,
      organizer: const EventOrganizer(
        id: 'user-1',
        name: 'Maria Oliveira',
        handle: 'maria_o',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventCard(
            event: event,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify Semantics
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == 'Evento: Passeio Acessível Parque Villa-Lobos, Local: Parque Villa-Lobos, Confirmados: 8',
      ),
      findsOneWidget,
    );

    // Verify Card renders
    expect(find.text('Passeio Acessível Parque Villa-Lobos'), findsOneWidget);
    expect(find.text('Parque Villa-Lobos'), findsOneWidget);
    expect(find.text('8 pessoas confirmadas'), findsOneWidget);
  });
}
