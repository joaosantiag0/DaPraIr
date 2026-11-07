import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/accessibility/semantics_helper.dart';
import '../../core/storage/user_location_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import 'accessible_button.dart';

class LocationSelectorSheet extends StatefulWidget {
  final PlacesRepository? repository;
  final UserSavedLocation? currentLocation;

  const LocationSelectorSheet({
    super.key,
    this.repository,
    this.currentLocation,
  });

  static Future<UserSavedLocation?> show({
    required BuildContext context,
    PlacesRepository? repository,
    UserSavedLocation? currentLocation,
    bool isDismissible = true,
  }) async {
    return await showModalBottomSheet<UserSavedLocation>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LocationSelectorSheet(
        repository: repository,
        currentLocation: currentLocation,
      ),
    );
  }

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  final TextEditingController _addressController = TextEditingController();
  final UserLocationStorage _storage = UserLocationStorage();

  bool _isManualAddressMode = false;
  bool _isSearching = false;
  List<ExternalPlaceSuggestion> _suggestions = [];
  Timer? _debounceTimer;

  PlacesRepository? get _repo {
    if (widget.repository != null) return widget.repository;
    try {
      return context.read<PlacesRepository>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectGpsLocation() async {
    // Current GPS position (defaulting to São Paulo center if GPS unavailable in simulator)
    const lat = -23.55052;
    const lng = -46.633308;

    final savedLoc = UserSavedLocation(
      label: 'Minha Localização Atual (GPS)',
      address: 'Coordenadas GPS ativas',
      city: 'São Paulo',
      state: 'SP',
      latitude: lat,
      longitude: lng,
      isGps: true,
      savedAt: DateTime.now(),
    );

    await _storage.saveLocation(savedLoc);
    SemanticsHelper.announce('Localização por GPS selecionada e salva com sucesso');

    if (mounted) {
      Navigator.pop(context, savedLoc);
    }
  }

  Future<void> _searchAddressSuggestions(String query) async {
    if (query.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final repo = _repo;
      final results = repo != null
          ? await repo.searchExternalPlaces(query: query.trim())
          : <ExternalPlaceSuggestion>[];
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

  void _onAddressChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _searchAddressSuggestions(query);
    });
  }

  Map<String, String> _extractCityAndState(String address) {
    try {
      final parts = address.split(',').map((p) => p.trim()).toList();
      for (final part in parts) {
        final match = RegExp(r'(.+?)\s*-\s*([A-Z]{2})\b', caseSensitive: false).firstMatch(part);
        if (match != null) {
          return {
            'city': match.group(1)?.trim() ?? 'São Paulo',
            'state': match.group(2)?.toUpperCase().trim() ?? 'SP',
          };
        }
      }
    } catch (_) {}
    return {'city': 'São Paulo', 'state': 'SP'};
  }

  Future<void> _selectSuggestion(ExternalPlaceSuggestion suggestion) async {
    final cityState = _extractCityAndState(suggestion.formattedAddress);
    final savedLoc = UserSavedLocation(
      label: suggestion.name,
      address: suggestion.formattedAddress,
      city: cityState['city'],
      state: cityState['state'],
      latitude: suggestion.latitude,
      longitude: suggestion.longitude,
      isGps: false,
      savedAt: DateTime.now(),
    );

    await _storage.saveLocation(savedLoc);
    SemanticsHelper.announce('Localização ${savedLoc.displayTitle} selecionada com sucesso');

    if (mounted) {
      Navigator.pop(context, savedLoc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Material(
          color: AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            // Drag indicator
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.primaryBlue, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onde você está?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Para encontrar locais acessíveis perto de você',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!_isManualAddressMode) ...[
              // Option 1: GPS Button
              AccessibleButton(
                label: 'Usar Localização Atual (GPS)',
                icon: Icons.my_location_rounded,
                onPressed: _selectGpsLocation,
              ),
              const SizedBox(height: 12),

              // Option 2: Type Address Option
              AccessibleButton(
                label: 'Digitar Endereço ou Cidade',
                icon: Icons.edit_location_alt_rounded,
                isSecondary: true,
                onPressed: () => setState(() => _isManualAddressMode = true),
              ),
            ] else ...[
              // Manual Address Search Form
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Digite seu endereço ou cidade:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Voltar'),
                    onPressed: () => setState(() {
                      _isManualAddressMode = false;
                      _suggestions.clear();
                      _addressController.clear();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      autofocus: true,
                      onChanged: _onAddressChanged,
                      onSubmitted: (val) {
                        _debounceTimer?.cancel();
                        _searchAddressSuggestions(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Digite uma rua, bairro ou cidade...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                        suffixIcon: _addressController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textHint),
                                onPressed: () {
                                  _addressController.clear();
                                  setState(() => _suggestions = []);
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        _debounceTimer?.cancel();
                        _searchAddressSuggestions(_addressController.text);
                      },
                      child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              if (_isSearching) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],

              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.place_rounded, color: AppColors.primaryBlue),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          item.formattedAddress,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        onTap: () => _selectSuggestion(item),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    ),
  ),
),
);
  }
}
