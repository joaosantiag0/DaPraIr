import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';

class OnboardingAccessibilityScreen extends StatefulWidget {
  const OnboardingAccessibilityScreen({super.key});

  @override
  State<OnboardingAccessibilityScreen> createState() => _OnboardingAccessibilityScreenState();
}

class _OnboardingAccessibilityScreenState extends State<OnboardingAccessibilityScreen> {
  final Set<String> _selectedDisabilities = {};
  final Set<String> _selectedNeeds = {};
  String _visibility = 'PRIVATE';
  bool _consentGranted = true;

  final List<Map<String, String>> _disabilityOptions = [
    {'code': 'WHEELCHAIR_MANUAL', 'label': 'Cadeira de Rodas Manual'},
    {'code': 'WHEELCHAIR_POWERED', 'label': 'Cadeira de Rodas Motorizada'},
    {'code': 'REDUCED_MOBILITY', 'label': 'Mobilidade Reduzida / Idoso'},
    {'code': 'PROSTHESIS_CRUTCHES', 'label': 'Uso de Prótese / Muletas'},
    {'code': 'TEMPORARY_INJURY', 'label': 'Lesão Temporária'},
  ];

  final List<Map<String, String>> _needsOptions = [
    {'code': 'RAMP_REQUIRED', 'label': 'Rampa de Acesso Nivelada'},
    {'code': 'ELEVATOR_REQUIRED', 'label': 'Elevador ou Plataforma'},
    {'code': 'ADAPTED_RESTROOM', 'label': 'Banheiro Adaptado com Barras'},
    {'code': 'WIDE_DOORS', 'label': 'Portas e Corredores Largos (>=90cm)'},
    {'code': 'RESERVED_PARKING', 'label': 'Vaga Reservada Próxima'},
  ];

  void _savePreferences() {
    context.read<ProfileBloc>().add(
          UpdateProfileEvent(
            disabilityTypes: _selectedDisabilities.toList(),
            assistanceNeeds: _selectedNeeds.toList(),
            visibility: _visibility,
            consentGranted: _consentGranted,
          ),
        );
    SemanticsHelper.announce('Preferências de acessibilidade salvas!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferências de Acessibilidade'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Pular', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Personalize sua Experiência',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O preenchimento é totalmente opcional. Suas preferências ajudam a sugerir locais mais adaptados e pares com vivências semelhantes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Disability Type Selection
            Text(
              'Tipo de Deficiência Física / Mobilidade (Opcional):',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _disabilityOptions.map((opt) {
                final isSelected = _selectedDisabilities.contains(opt['code']);
                return FilterChip(
                  label: Text(opt['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDisabilities.add(opt['code']!);
                      } else {
                        _selectedDisabilities.remove(opt['code']!);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Assistance Needs Selection
            Text(
              'Recursos de Acessibilidade Prioritários para Você:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _needsOptions.map((opt) {
                final isSelected = _selectedNeeds.contains(opt['code']);
                return FilterChip(
                  label: Text(opt['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedNeeds.add(opt['code']!);
                      } else {
                        _selectedNeeds.remove(opt['code']!);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Visibility Granular Setting (LGPD)
            Text(
              'Quem pode ver minhas preferências de acessibilidade?',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _visibility,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'PRIVATE', child: Text('Apenas Eu (Privado)')),
                DropdownMenuItem(value: 'FRIENDS_ONLY', child: Text('Apenas Amigos Aceitos')),
                DropdownMenuItem(value: 'PUBLIC', child: Text('Toda a Comunidade (Público)')),
              ],
              onChanged: (val) => setState(() => _visibility = val ?? 'PRIVATE'),
            ),

            const SizedBox(height: 20),

            // Consent Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryBlue),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _consentGranted,
                    onChanged: (val) => setState(() => _consentGranted = val ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Autorizo o uso das minhas preferências de acessibilidade para personalizar as recomendações no DáPraIr.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            AccessibleButton(
              label: 'Salvar e Concluir',
              onPressed: _savePreferences,
            ),
          ],
        ),
      ),
    );
  }
}
