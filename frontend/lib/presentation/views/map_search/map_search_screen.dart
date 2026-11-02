import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/places/places_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_card.dart';
import '../../components/accessible_button.dart';
import '../../components/guest_action_dialog.dart';
import '../place/place_detail_screen.dart';

class MapSearchScreen extends StatefulWidget {
  final bool isAuthenticated;
  final VoidCallback? onNavigateToLogin;

  const MapSearchScreen({
    super.key,
    this.isAuthenticated = false,
    this.onNavigateToLogin,
  });

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedCriteria = {};

  final List<Map<String, String>> _filterOptions = [
    {'code': 'ENTRANCE_RAMP_LEVEL', 'label': 'Rampa de Acesso'},
    {'code': 'ADAPTED_BATHROOM', 'label': 'Banheiro Adaptado'},
    {'code': 'ELEVATOR_LIFT', 'label': 'Elevador'},
    {'code': 'ACCESSIBLE_PARKING', 'label': 'Vaga Reservada'},
  ];

  @override
  void initState() {
    super.initState();
    // Default search around São Paulo center
    _triggerSearch();
  }

  void _triggerSearch() {
    context.read<PlacesBloc>().add(
          SearchPlacesEvent(
            latitude: -23.55052,
            longitude: -46.633308,
            query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
            requiredCriteria: _selectedCriteria.toList(),
          ),
        );
  }

  void _toggleCriterion(String code) {
    setState(() {
      if (_selectedCriteria.contains(code)) {
        _selectedCriteria.remove(code);
      } else {
        _selectedCriteria.add(code);
      }
    });
    _triggerSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Locais Acessíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Usar minha localização GPS atual',
            onPressed: () {
              SemanticsHelper.announce('Buscando locais próximos pelo GPS');
              _triggerSearch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: 'Cadastrar novo local comunitariamente',
            onPressed: () {
              if (!widget.isAuthenticated) {
                GuestActionDialog.show(
                  context: context,
                  actionTitle: 'cadastrar um novo local acessível',
                  onLoginPressed: widget.onNavigateToLogin ?? () {},
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Semantics(
              textField: true,
              label: 'Pesquisar local por nome ou endereço digitado',
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _triggerSearch(),
                decoration: InputDecoration(
                  hintText: 'Buscar restaurantes, parques, museus...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Limpar texto da busca',
                          onPressed: () {
                            _searchController.clear();
                            _triggerSearch();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filterOptions.map((opt) {
                final isSelected = _selectedCriteria.contains(opt['code']);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(opt['label']!),
                    selected: isSelected,
                    onSelected: (_) => _toggleCriterion(opt['code']!),
                    selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryBlue,
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Results List
          Expanded(
            child: BlocBuilder<PlacesBloc, PlacesState>(
              builder: (context, state) {
                if (state is PlacesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PlacesError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.warningOrange),
                          const SizedBox(height: 12),
                          Text('Erro ao carregar locais: ${state.message}', textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          AccessibleButton(label: 'Tentar Novamente', onPressed: _triggerSearch),
                        ],
                      ),
                    ),
                  );
                }

                if (state is PlacesLoaded) {
                  if (state.places.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhum local acessível encontrado com os filtros selecionados.',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.places.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final place = state.places[index];
                      return AccessibleCard(
                        semanticLabel:
                            '${place.name}, categoria ${place.category}, ${SemanticsHelper.formatRatingAnnouncement(place.overallScore, place.totalReviews)}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailScreen(
                                placeId: place.id,
                                initialPlace: place,
                                isAuthenticated: widget.isAuthenticated,
                                onNavigateToLogin: widget.onNavigateToLogin,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        place.address,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        place.overallScore.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (place.isOutdated) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warningOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.warningOrange),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warningOrange),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Avaliação há mais de 12 meses',
                                      style: TextStyle(
                                        color: AppColors.warningOrange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
