import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/events/events_bloc.dart';
import '../../../domain/entities/event.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/responsive_container.dart';
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
            icon: const Icon(Icons.add_circle_outline, size: 26),
            tooltip: 'Criar Evento Inclusivo',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              );
            },
          ),
        ],
      ),
      body: ResponsiveContainer.wide(
        child: Column(
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
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.surfaceLight,
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ).paddingMinTouchTarget();
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          Expanded(
            child: BlocBuilder<EventsBloc, EventsState>(
              builder: (context, state) {
                if (state.status == EventsStatus.loading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Buscando eventos inclusivos...'),
                      ],
                    ),
                  );
                }

                if (state.status == EventsStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.warningLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline, size: 48, color: AppColors.warningOrange),
                          ),
                          const SizedBox(height: 16),
                          Text('Erro ao carregar eventos: ${state.errorMessage}'),
                          const SizedBox(height: 16),
                          AccessibleButton(
                            label: 'Tentar novamente',
                            icon: Icons.refresh,
                            onPressed: () => context.read<EventsBloc>().add(const LoadEventsRequested()),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.events.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.event_busy_rounded, size: 54, color: AppColors.textHint),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum evento inclusivo encontrado para este filtro.\nSeja o primeiro a organizar um!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 20),
                          AccessibleButton(
                            label: 'Criar Novo Evento',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                              );
                            },
                          ),
                        ],
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
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 0.8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1.2),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date calendar pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${event.startTime.day}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Text(
                            _getMonthAbbr(event.startTime.month),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.locationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textHint,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (event.isAttending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.successGreen.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 14, color: AppColors.successGreen),
                            SizedBox(width: 3),
                            Text(
                              'Confirmado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Text(
                      '$confirmedCount pessoas confirmadas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                if (event.accessibilityChecklist.values.any((v) => v)) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: event.accessibilityChecklist.entries
                        .where((e) => e.value)
                        .take(3)
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Text(
                                e.key.replaceAll('_', ' '),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _getMonthAbbr(int month) {
    const months = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
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
