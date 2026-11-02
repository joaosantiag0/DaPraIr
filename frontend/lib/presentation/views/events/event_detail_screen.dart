import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/event.dart';
import '../../bloc/events/events_bloc.dart';
import '../../components/accessible_button.dart';
import '../../../core/navigation/external_navigation_launcher.dart';

class EventDetailScreen extends StatelessWidget {
  final EventItem event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        // Find current version of event from state if updated
        final currentEvent = state.events.firstWhere(
          (e) => e.id == event.id,
          orElse: () => event,
        );

        final isAttending = currentEvent.isAttending;

        return Scaffold(
          appBar: AppBar(
            title: Text(currentEvent.title),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  currentEvent.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Organizado por: ${currentEvent.organizer.name} (@${currentEvent.organizer.handle})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Início: ${dateFormat.format(currentEvent.startTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Término: ${dateFormat.format(currentEvent.endTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${currentEvent.locationName}\n${currentEvent.address}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        if (currentEvent.latitude != null && currentEvent.longitude != null) ...[
                          const SizedBox(height: 12),
                          AccessibleButton(
                            label: 'Como Chegar (Navegar)',
                            isSecondary: true,
                            icon: Icons.navigation,
                            onPressed: () {
                              ExternalNavigationLauncher.launchNavigation(
                                latitude: currentEvent.latitude!,
                                longitude: currentEvent.longitude!,
                                destinationName: currentEvent.locationName,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sobre o Evento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentEvent.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Condições de Acessibilidade Declaradas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentEvent.accessibilityChecklist.entries.map((entry) {
                    final isAvailable = entry.value;
                    return Chip(
                      avatar: Icon(
                        isAvailable ? Icons.check_circle : Icons.cancel,
                        color: isAvailable ? Colors.green : Colors.grey,
                        size: 18,
                      ),
                      label: Text(
                        entry.key.replaceAll('_', ' '),
                        style: TextStyle(
                          color: isAvailable ? null : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Card(
                  color: isAttending ? Colors.green.shade50 : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${currentEvent.rsvpCount} participante(s) confirmado(s)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        AccessibleButton(
                          label: isAttending ? 'Cancelar Presença' : 'Confirmar Presença (RSVP)',
                          isSecondary: isAttending,
                          icon: isAttending ? Icons.check : Icons.event_available,
                          onPressed: () {
                            context.read<EventsBloc>().add(
                                  ToggleRSVPRequested(
                                    eventId: currentEvent.id,
                                    currentlyAttending: isAttending,
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
