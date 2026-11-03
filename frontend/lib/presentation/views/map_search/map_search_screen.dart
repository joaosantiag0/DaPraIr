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

  final List<Map<String, dynamic>> _filterOptions = [
    {'code': 'ENTRANCE_RAMP_LEVEL', 'label': 'Rampa de Acesso', 'icon': Icons.accessible_forward},
    {'code': 'ADAPTED_BATHROOM', 'label': 'Banheiro Adaptado', 'icon': Icons.wc},
    {'code': 'ELEVATOR_LIFT', 'label': 'Elevador', 'icon': Icons.elevator},
    {'code': 'ACCESSIBLE_PARKING', 'label': 'Vaga Reservada', 'icon': Icons.local_parking},
  ];

  @override
  void initState() {
    super.initState();
    // Default search around São Paulo center
    _triggerSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _clearFilters() {
    setState(() {
      _selectedCriteria.clear();
      _searchController.clear();
    });
    _triggerSearch();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'RESTAURANT':
        return Icons.restaurant;
      case 'PARK':
        return Icons.park;
      case 'MUSEUM':
        return Icons.museum;
      case 'THEATER':
        return Icons.theater_comedy;
      case 'SHOPPING':
      case 'STORE':
        return Icons.shopping_bag;
      case 'HEALTH':
      case 'HOSPITAL':
        return Icons.local_hospital;
      default:
        return Icons.place;
    }
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
          // Search Input Container
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Semantics(
              textField: true,
              label: 'Pesquisar local por nome ou endereço digitado',
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _triggerSearch(),
                  decoration: InputDecoration(
                    hintText: 'Buscar restaurantes, parques, museus...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textHint),
                            tooltip: 'Limpar texto da busca',
                            onPressed: () {
                              _searchController.clear();
                              _triggerSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.borderLight, width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.borderLight, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Horizontal Filter Chips with Icons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                if (_selectedCriteria.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      avatar: const Icon(Icons.filter_alt, size: 16, color: AppColors.primaryBlue),
                      label: Text(
                        '${_selectedCriteria.length} filtro${_selectedCriteria.length > 1 ? "s" : ""}',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.primaryContainer,
                      onPressed: _clearFilters,
                    ),
                  ),
                ..._filterOptions.map((opt) {
                  final isSelected = _selectedCriteria.contains(opt['code']);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      avatar: Icon(
                        opt['icon'] as IconData,
                        size: 18,
                        color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                      ),
                      label: Text(opt['label'] as String),
                      selected: isSelected,
                      onSelected: (_) => _toggleCriterion(opt['code'] as String),
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
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Results List
          Expanded(
            child: BlocBuilder<PlacesBloc, PlacesState>(
              builder: (context, state) {
                if (state is PlacesLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Localizando estabelecimentos acessíveis...',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PlacesError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
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
                          Text(
                            'Erro ao carregar locais',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          AccessibleButton(
                            label: 'Tentar Novamente',
                            icon: Icons.refresh,
                            onPressed: _triggerSearch,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is PlacesLoaded) {
                  if (state.places.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textHint),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum local acessível encontrado com os filtros selecionados.',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Experimente buscar por outros termos ou limpar os critérios exigidos.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            if (_selectedCriteria.isNotEmpty || _searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              AccessibleButton(
                                label: 'Limpar Filtros',
                                icon: Icons.clear_all,
                                isSecondary: true,
                                onPressed: _clearFilters,
                              ),
                            ],
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
                                // Category icon container
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(place.category),
                                    color: AppColors.primaryBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.2,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              place.address,
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
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, size: 18, color: AppColors.starGold),
                                      const SizedBox(width: 4),
                                      Text(
                                        place.overallScore.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Color(0xFF92400E),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (place.isOutdated) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.warningOrange.withOpacity(0.5)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warningOrange),
                                    SizedBox(width: 6),
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
