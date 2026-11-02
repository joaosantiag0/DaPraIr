import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/reviews/reviews_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_text_field.dart';

class SubmitReviewScreen extends StatefulWidget {
  final String placeId;

  const SubmitReviewScreen({super.key, required this.placeId});

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _altTextController = TextEditingController();

  final Map<String, int> _ratings = {
    'ENTRANCE_RAMP_LEVEL': 5,
    'ELEVATOR_LIFT': 5,
    'ADAPTED_BATHROOM': 5,
    'MANEUVERING_SPACE': 4,
    'ADAPTED_SEATING': 4,
    'ACCESSIBLE_PARKING': 5,
    'INCLUSIVE_SERVICE': 5,
  };

  final List<Map<String, String>> _criteriaList = [
    {'code': 'ENTRANCE_RAMP_LEVEL', 'title': 'Entrada com Rampa ou Nivelada'},
    {'code': 'ELEVATOR_LIFT', 'title': 'Elevador ou Plataforma Elevatória'},
    {'code': 'ADAPTED_BATHROOM', 'title': 'Banheiro Adaptado'},
    {'code': 'MANEUVERING_SPACE', 'title': 'Espaço de Circulação e Manobra'},
    {'code': 'ADAPTED_SEATING', 'title': 'Assentos e Mesas Acessíveis'},
    {'code': 'ACCESSIBLE_PARKING', 'title': 'Vagas Reservadas'},
    {'code': 'INCLUSIVE_SERVICE', 'title': 'Atendimento Inclusivo'},
  ];

  bool _isSavingDraft = false;
  bool _hasPhotoAttached = false;

  @override
  void initState() {
    super.initState();
    context.read<ReviewsBloc>().add(LoadReviewDraftEvent(widget.placeId));
  }

  void _saveDraft() {
    setState(() => _isSavingDraft = true);
    context.read<ReviewsBloc>().add(
          SaveReviewDraftEvent(
            placeId: widget.placeId,
            generalComment: _commentController.text,
            ratings: _ratings,
          ),
        );
    SemanticsHelper.announce('Rascunho de avaliação salvo no dispositivo');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rascunho salvo offline!')),
    );
    setState(() => _isSavingDraft = false);
  }

  void _submitReview() {
    if (_hasPhotoAttached && _altTextController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warningOrange,
          content: Text('Para anexar uma foto, a audiodescrição (alt_text) com pelo menos 5 caracteres é obrigatória!'),
        ),
      );
      return;
    }

    final ratingsList = _ratings.entries
        .map((e) => {'criterionCode': e.key, 'score': e.value})
        .toList();

    context.read<ReviewsBloc>().add(
          SubmitReviewEvent(
            placeId: widget.placeId,
            generalComment: _commentController.text.trim(),
            ratings: ratingsList,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Avaliação'),
        actions: [
          TextButton(
            onPressed: _isSavingDraft ? null : _saveDraft,
            child: const Text('Salvar Rascunho', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: BlocListener<ReviewsBloc, ReviewsState>(
        listener: (context, state) {
          if (state is ReviewsLoaded && state.submitSuccess) {
            SemanticsHelper.announce('Avaliação publicada com sucesso');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avaliação publicada com sucesso!')),
            );
            Navigator.pop(context);
          }
          if (state is ReviewsLoaded && state.draft != null) {
            final draft = state.draft!;
            if (draft['generalComment'] != null && _commentController.text.isEmpty) {
              _commentController.text = draft['generalComment'] as String;
            }
            if (draft['ratings'] is Map) {
              final draftRatings = draft['ratings'] as Map<String, dynamic>;
              setState(() {
                draftRatings.forEach((k, v) {
                  if (_ratings.containsKey(k)) {
                    _ratings[k] = (v as num).toInt();
                  }
                });
              });
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Notas de Acessibilidade (1 a 5)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Avalie os itens que você teve oportunidade de observar:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // 7 Criteria Rating Controls
              ..._criteriaList.map((crit) {
                final code = crit['code']!;
                final title = crit['title']!;
                final currentScore = _ratings[code] ?? 5;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            final score = index + 1;
                            final isSelected = score <= currentScore;
                            return Semantics(
                              button: true,
                              label: 'Nota $score de 5 para $title',
                              selected: score == currentScore,
                              child: InkWell(
                                onTap: () {
                                  setState(() => _ratings[code] = score);
                                  SemanticsHelper.announce('$title avaliado com $score estrelas');
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48, // Minimum 48x48 dp touch target
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    isSelected ? Icons.star : Icons.star_border,
                                    size: 32,
                                    color: isSelected ? Colors.amber.shade700 : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Remarks
              AccessibleTextField(
                controller: _commentController,
                label: 'Comentários e Dicas de Acessibilidade (Opcional)',
                hint: 'Ex: A rampa é bem espaçosa, porém a porta do banheiro é pesada...',
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // Photo attachment with mandatory alt_text
              Semantics(
                header: true,
                child: Text(
                  'Comprovação Fotográfica (Opcional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  AccessibleButton(
                    label: _hasPhotoAttached ? 'Foto Anexada ✓' : 'Anexar Foto',
                    icon: Icons.camera_alt,
                    isSecondary: true,
                    onPressed: () {
                      setState(() => _hasPhotoAttached = !_hasPhotoAttached);
                    },
                  ),
                ],
              ),

              if (_hasPhotoAttached) ...[
                const SizedBox(height: 12),
                AccessibleTextField(
                  controller: _altTextController,
                  label: 'Audiodescrição Obrigatória da Foto (alt_text)',
                  hint: 'Descreva os elementos de acessibilidade visíveis na foto para quem usa leitor de tela',
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 28),

              // Submit Button
              BlocBuilder<ReviewsBloc, ReviewsState>(
                builder: (context, state) {
                  return AccessibleButton(
                    label: 'Publicar Avaliação',
                    isLoading: state is ReviewsLoading,
                    onPressed: _submitReview,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
