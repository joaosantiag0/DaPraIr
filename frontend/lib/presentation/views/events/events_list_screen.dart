import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/events/events_bloc.dart';
import '../../../domain/entities/event.dart';
import '../../components/accessible_button.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final List<Map<String, String>> _filters = [
    {'key': '', 'label': 'Todos'},
    {'key': 'rampa_acesso', 'label': 'Rampa de Acesso'},
    {'key': 'banheiro_adaptado', 'label': 'Banheiro Adaptado'},
    {'key': 'elevador', 'label': 'Elevador'},
    {'key': 'interprete_libras', 'label': 'Intérprete de Libras'},
    {'key': 'guia_cego', 'label': 'Guia para Cegos'},
  ];

  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<EventsBloc>().add(const LoadEventsRequested());
  }

  void _onFilterSelected(String key) {
    setState(() {
      _selectedFilter = key;
    });
    context.read<EventsBloc>().add(LoadEventsRequested(
      accessibilityFeature: key.isEmpty ? null : key,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Inclusivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            tooltip: 'Criar Evento Inclusivo',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Accessibility Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: 'Filtrar por ${filter['label']}',
                    child: FilterChip(
                      label: Text(filter['label']!),
                      selected: isSelected,
                      onSelected: (_) => _onFilterSelected(filter['key']!),
                    ),
                  ),
                ).paddingMinTouchTarget();
              }).toList(),
            ),
          ),
          Expanded(
            child: BlocBuilder<EventsBloc, EventsState>(
              builder: (context, state) {
                if (state.status == EventsStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == EventsStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erro ao carregar eventos: ${state.errorMessage}'),
                        const SizedBox(height: 16),
                        AccessibleButton(
                          label: 'Tentar novamente',
                          onPressed: () => context.read<EventsBloc>().add(const LoadEventsRequested()),
                        ),
                      ],
                    ),
                  );
                }

                if (state.events.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhum evento inclusivo encontrado para este filtro.\nSeja o primeiro a organizar um!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.events.length,
                  itemBuilder: (context, index) {
                    final event = state.events[index];
                    return EventCard(
                      event: event,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final confirmedCount = event.rsvpCount;
    final semanticLabel =
        'Evento: ${event.title}, Local: ${event.locationName}, Confirmados: $confirmedCount';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (event.isAttending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Confirmado', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.locationName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$confirmedCount pessoas confirmadas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: event.accessibilityChecklist.entries
                      .where((e) => e.value)
                      .take(3)
                      .map((e) => Chip(
                            label: Text(e.key.replaceAll('_', ' '), style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension PaddingMinTouchTarget on Widget {
  Widget paddingMinTouchTarget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
      child: Center(child: this),
    );
  }
}
