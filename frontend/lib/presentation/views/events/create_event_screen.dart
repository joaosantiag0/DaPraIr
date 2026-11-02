import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/events/events_bloc.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  final DateTime _startTime = DateTime.now().add(const Duration(days: 1));
  final DateTime _endTime = DateTime.now().add(const Duration(days: 1, hours: 2));

  final Map<String, bool> _accessibilityChecklist = {
    'rampa_acesso': false,
    'porta_larga': false,
    'banheiro_adaptado': false,
    'elevador': false,
    'piso_tatil': false,
    'interprete_libras': false,
    'guia_cego': false,
    'estacionamento_pcd': false,
  };

  final Map<String, String> _criteriaLabels = {
    'rampa_acesso': 'Rampa de acesso ou entrada em nível',
    'porta_larga': 'Portas largas (>= 80cm)',
    'banheiro_adaptado': 'Banheiro acessível adaptado',
    'elevador': 'Elevador com acessibilidade',
    'piso_tatil': 'Piso tátil direcional/alerta',
    'interprete_libras': 'Intérprete de Libras disponível',
    'guia_cego': 'Apoio de guia para pessoas cegas',
    'estacionamento_pcd': 'Vaga de estacionamento PCD reservada',
  };

  bool _checklistError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  void _submit() {
    final hasAnyCondition = _accessibilityChecklist.values.any((v) => v);
    if (!hasAnyCondition) {
      setState(() {
        _checklistError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atenção: É obrigatório declarar pelo menos 1 condição de acessibilidade do evento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      context.read<EventsBloc>().add(
            CreateEventRequested(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              startTime: _startTime,
              endTime: _endTime,
              locationName: _locationController.text.trim(),
              address: _addressController.text.trim(),
              accessibilityChecklist: _accessibilityChecklist,
              maxAttendees: int.tryParse(_maxAttendeesController.text.trim()),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) {
        if (state.status == EventsStatus.created) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento criado com sucesso!')),
          );
          Navigator.of(context).pop();
        } else if (state.status == EventsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Erro ao criar evento'), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Criar Evento Inclusivo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccessibleTextField(
                  controller: _titleController,
                  label: 'Título do Evento *',
                  hint: 'Ex: Encontro no Parque Ibirapuera',
                  validator: (v) => (v == null || v.trim().length < 3) ? 'Título deve ter ao menos 3 caracteres' : null,
                ),
                const SizedBox(height: 16),
                AccessibleTextField(
                  controller: _locationController,
                  label: 'Nome do Local *',
                  hint: 'Ex: Portão 3 - Parque Ibirapuera',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome do local é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                AccessibleTextField(
                  controller: _addressController,
                  label: 'Endereço Completo *',
                  hint: 'Av. Pedro Álvares Cabral, s/n',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Endereço é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                AccessibleTextField(
                  controller: _descController,
                  label: 'Descrição do Evento *',
                  hint: 'Detalhes da programação, ponto de encontro...',
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Descrição deve ter ao menos 10 caracteres' : null,
                ),
                const SizedBox(height: 16),
                AccessibleTextField(
                  controller: _maxAttendeesController,
                  label: 'Lotação Máxima (opcional)',
                  hint: 'Ex: 30',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                // Mandatory Accessibility Checklist section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _checklistError ? Colors.red : Colors.grey.shade300,
                      width: _checklistError ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Condições de Acessibilidade Física (Obrigatório) *',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _checklistError ? Colors.red : null,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Declare ao menos um recurso de acessibilidade garantido no evento:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Divider(),
                        ..._criteriaLabels.entries.map((entry) {
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.value),
                            value: _accessibilityChecklist[entry.key],
                            onChanged: (val) {
                              setState(() {
                                _accessibilityChecklist[entry.key] = val ?? false;
                                if (_accessibilityChecklist.values.any((v) => v)) {
                                  _checklistError = false;
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<EventsBloc, EventsState>(
                  builder: (context, state) {
                    return AccessibleButton(
                      label: 'Publicar Evento Inclusivo',
                      isLoading: state.status == EventsStatus.creating,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
