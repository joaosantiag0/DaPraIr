import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/places/places_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/repositories/places_repository.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_text_field.dart';
import '../../components/responsive_container.dart';
import 'submit_review_screen.dart';

class CreatePlaceScreen extends StatefulWidget {
  final PlacesRepository? placesRepository;

  const CreatePlaceScreen({super.key, this.placesRepository});

  @override
  State<CreatePlaceScreen> createState() => _CreatePlaceScreenState();
}

class _CreatePlaceScreenState extends State<CreatePlaceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _searchGoogleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'São Paulo');
  final TextEditingController _stateController = TextEditingController(text: 'SP');
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _latController = TextEditingController(text: '-23.55052');
  final TextEditingController _lngController = TextEditingController(text: '-46.633308');

  String _selectedCategory = 'Restaurante';
  String? _submittingPlaceId;
  bool _isSearchingGoogle = false;
  String? _googleSearchError;
  List<ExternalPlaceSuggestion> _googleSuggestions = [];
  bool _isSubmitting = false;
  bool _isManualMode = false;
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Restaurante', 'icon': Icons.restaurant},
    {'name': 'Café', 'icon': Icons.local_cafe},
    {'name': 'Bar', 'icon': Icons.local_bar},
    {'name': 'Comércio', 'icon': Icons.storefront},
    {'name': 'Parque', 'icon': Icons.park},
    {'name': 'Museu', 'icon': Icons.museum},
    {'name': 'Saúde', 'icon': Icons.local_hospital},
    {'name': 'Hotel', 'icon': Icons.hotel},
    {'name': 'Cultura', 'icon': Icons.theater_comedy},
    {'name': 'Outro', 'icon': Icons.place},
  ];

  PlacesRepository get _repository {
    if (widget.placesRepository != null) return widget.placesRepository!;
    try {
      return context.read<PlacesRepository>();
    } catch (_) {
      return context.read<PlacesBloc>().repository;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbyPlaces();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchGoogleController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      _loadNearbyPlaces();
      return;
    }
    // Timeout de 750ms desde a última letra para evitar disparos contínuos e telas piscando
    _debounceTimer = Timer(const Duration(milliseconds: 750), () {
      _loadNearbyPlaces(query);
    });
  }

  void _performSearch() {
    _debounceTimer?.cancel();
    _loadNearbyPlaces(_searchGoogleController.text);
  }

  Future<void> _loadNearbyPlaces([String? query]) async {
    setState(() {
      _isSearchingGoogle = true;
      _googleSearchError = null;
    });

    try {
      final trimmed = query?.trim();
      final hasQuery = trimmed != null && trimmed.isNotEmpty;
      final results = await _repository.searchExternalPlaces(
        query: hasQuery ? trimmed : null,
        latitude: hasQuery ? null : -23.55052,
        longitude: hasQuery ? null : -46.633308,
      );

      if (mounted) {
        setState(() {
          _googleSuggestions = results;
          _isSearchingGoogle = false;
        });
        if (results.isNotEmpty) {
          SemanticsHelper.announce('${results.length} locais encontrados');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _googleSearchError = 'Não foi possível buscar locais no momento.';
          _isSearchingGoogle = false;
        });
      }
    }
  }

  Map<String, String> _extractCityAndState(String address) {
    final regex = RegExp(r'([A-Za-zÀ-ÖØ-öø-ÿ\s]+)\s*-\s*([A-Z]{2})');
    final match = regex.firstMatch(address);
    if (match != null) {
      final cityCandidate = match.group(1)?.split(',').last.trim();
      final ufCandidate = match.group(2)?.trim();
      return {
        'city': (cityCandidate != null && cityCandidate.isNotEmpty) ? cityCandidate : 'São Paulo',
        'state': (ufCandidate != null && ufCandidate.length == 2) ? ufCandidate : 'SP',
      };
    }
    return {'city': 'São Paulo', 'state': 'SP'};
  }

  void _submitGooglePlace(ExternalPlaceSuggestion suggestion) {
    if (suggestion.alreadyImportedId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubmitReviewScreen(placeId: suggestion.alreadyImportedId!),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submittingPlaceId = suggestion.googlePlaceId;
    });

    final matchingCategory = _categories.firstWhere(
      (c) => (c['name'] as String).toLowerCase() == suggestion.category.toLowerCase(),
      orElse: () => {'name': 'Restaurante'},
    );

    final geoInfo = _extractCityAndState(suggestion.formattedAddress);

    SemanticsHelper.announce('Abrindo avaliação para ${suggestion.name}...');

    context.read<PlacesBloc>().add(
          CreatePlaceEvent(
            name: suggestion.name,
            category: matchingCategory['name'] as String,
            address: suggestion.formattedAddress,
            city: geoInfo['city']!,
            state: geoInfo['state']!,
            latitude: suggestion.latitude,
            longitude: suggestion.longitude,
            googlePlaceId: suggestion.googlePlaceId,
          ),
        );
  }

  void _submitManual() {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (name.length < 2) {
      _showWarning('O nome do local deve conter pelo menos 2 caracteres.');
      return;
    }
    if (address.length < 5) {
      _showWarning('O endereço deve conter pelo menos 5 caracteres.');
      return;
    }
    if (city.length < 2) {
      _showWarning('Preencha a cidade.');
      return;
    }
    if (state.length < 2) {
      _showWarning('Preencha o estado (UF).');
      return;
    }
    if (lat == null || lng == null) {
      _showWarning('Coordenadas de latitude e longitude inválidas.');
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<PlacesBloc>().add(
          CreatePlaceEvent(
            name: name,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            category: _selectedCategory,
            address: address,
            city: city,
            state: state,
            postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
            latitude: lat,
            longitude: lng,
          ),
        );
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.warningOrange,
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isManualMode ? 'Cadastrar Manualmente' : 'Adicionar Novo Local'),
        leading: _isManualMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Voltar para busca',
                onPressed: () => setState(() => _isManualMode = false),
              )
            : null,
      ),
      body: BlocConsumer<PlacesBloc, PlacesState>(
        listener: (context, state) {
          if (state is PlacesLoaded && state.selectedPlace != null && _isSubmitting) {
            _isSubmitting = false;
            _submittingPlaceId = null;
            SemanticsHelper.announce('Local pronto para avaliação!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SubmitReviewScreen(
                  placeId: state.selectedPlace!.id,
                ),
              ),
            );
          } else if (state is PlacesError && _isSubmitting) {
            _isSubmitting = false;
            _submittingPlaceId = null;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.warningOrange,
                content: Text('Falha ao registrar local: ${state.message}'),
              ),
            );
          }
        },
        builder: (context, state) {
          final content = _isManualMode ? _buildManualForm(state) : _buildPlacesSearch(state);
          return ResponsiveContainer.medium(child: content);
        },
      ),
    );
  }

  Widget _buildPlacesSearch(PlacesState state) {
    final query = _searchGoogleController.text.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner informativo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.travel_explore_rounded, color: AppColors.primaryBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Busque o estabelecimento para adicionar com 1 clique e avaliar sua acessibilidade.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Search Bar com Botão Buscar explícito e debounce
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchGoogleController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do local ou endereço...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                    suffixIcon: _searchGoogleController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Limpar busca',
                            onPressed: () {
                              _searchGoogleController.clear();
                              _loadNearbyPlaces();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  key: const Key('btn_search_places'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: _isSearchingGoogle ? null : _performSearch,
                  icon: _isSearchingGoogle
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.search, size: 20),
                  label: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          // Barra suave de progresso sem piscar nem sumir com a lista existente
          if (_isSearchingGoogle) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: AppColors.surfaceLight,
              color: AppColors.primaryBlue,
            ),
          ],

          if (_googleSearchError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(_googleSearchError!, style: const TextStyle(color: AppColors.warningOrange, fontSize: 13)),
              ),
            ),

          const SizedBox(height: 16),

          // Title for suggestions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                query.isEmpty
                    ? 'Locais Próximos a Você'
                    : 'Resultados para "$query"',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              if (query.isEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18, color: AppColors.primaryBlue),
                  tooltip: 'Recarregar próximos',
                  onPressed: () => _loadNearbyPlaces(),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Empty state for search
          if (_googleSuggestions.isEmpty && !_isSearchingGoogle)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  query.isEmpty
                      ? 'Nenhum estabelecimento próximo encontrado.'
                      : 'Nenhum resultado encontrado para "$query".',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
            )
          else
            // Suggestions List permanece estável na tela
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _googleSuggestions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final suggestion = _googleSuggestions[index];
                final isImported = suggestion.alreadyImportedId != null;
                final isThisSubmitting = _isSubmitting && _submittingPlaceId == suggestion.googlePlaceId;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        child: const Icon(Icons.place, color: AppColors.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              suggestion.formattedAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    suggestion.category,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                                  ),
                                ),
                                if (isImported) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.successGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Já no DáPraIr',
                                      style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          key: Key('btn_action_${suggestion.googlePlaceId}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isImported ? AppColors.surfaceLight : AppColors.primaryBlue,
                            foregroundColor: isImported ? AppColors.primaryBlue : Colors.white,
                            elevation: 0,
                            side: isImported ? const BorderSide(color: AppColors.primaryBlue) : BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: (isThisSubmitting || _isSubmitting)
                              ? null
                              : () => _submitGooglePlace(suggestion),
                          icon: isThisSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.star_rate_rounded, size: 18),
                          label: const Text(
                            'Avaliar',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 28),

          // Seção "Não encontrei o local -> Cadastrar manualmente"
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Column(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppColors.textSecondary, size: 28),
                const SizedBox(height: 8),
                const Text(
                  'Não encontrou o estabelecimento na lista?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Você pode cadastrar manualmente um espaço comunitário ou novo estabelecimento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('btn_open_manual_form'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.edit_location_alt_rounded, size: 20),
                  label: const Text('Cadastrar Local Manualmente', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    setState(() => _isManualMode = true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildManualForm(PlacesState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botão para retornar à busca
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _isManualMode = false),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Voltar para a busca'),
              ),
            ),
            const SizedBox(height: 8),

            // Guidance Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_location_alt_rounded, color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Preencha os dados do local manualmente. Todas as informações poderão ser avaliadas pela comunidade.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Place name
            AccessibleTextField(
              controller: _nameController,
              label: 'Nome do Estabelecimento *',
              hint: 'Ex: Restaurante Sabor Inclusivo',
            ),
            const SizedBox(height: 18),

            // Category selector
            Semantics(
              label: 'Selecione a categoria do local',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categoria *',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['name'] as String,
                            child: Row(
                              children: [
                                Icon(cat['icon'] as IconData, size: 20, color: AppColors.primaryBlue),
                                const SizedBox(width: 10),
                                Text(
                                  cat['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Address
            AccessibleTextField(
              controller: _addressController,
              label: 'Endereço Completo *',
              hint: 'Ex: Av. Paulista, 1578 - Bela Vista',
            ),
            const SizedBox(height: 18),

            // City and State Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AccessibleTextField(
                    controller: _cityController,
                    label: 'Cidade *',
                    hint: 'São Paulo',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: AccessibleTextField(
                    controller: _stateController,
                    label: 'UF *',
                    hint: 'SP',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Description
            AccessibleTextField(
              controller: _descriptionController,
              label: 'Descrição Geral (Opcional)',
              hint: 'Descreva o local e referências úteis de localização',
              maxLines: 3,
            ),
            const SizedBox(height: 18),

            // Coordinates Section
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.my_location, color: AppColors.primaryBlue),
              title: const Text(
                'Coordenadas Geográficas (GPS)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                'Lat: ${_latController.text}, Lng: ${_lngController.text}',
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: AccessibleTextField(
                          controller: _latController,
                          label: 'Latitude',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AccessibleTextField(
                          controller: _lngController,
                          label: 'Longitude',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Submit Button
            AccessibleButton(
              label: 'Cadastrar Local',
              icon: Icons.check_circle_rounded,
              isLoading: state is PlacesLoading && _isSubmitting,
              onPressed: _submitManual,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
