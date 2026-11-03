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

  final List<Map<String, dynamic>> _criteriaList = [
    {'code': 'ENTRANCE_RAMP_LEVEL', 'title': 'Entrada com Rampa ou Nivelada', 'icon': Icons.accessible_forward},
    {'code': 'ELEVATOR_LIFT', 'title': 'Elevador ou Plataforma Elevatória', 'icon': Icons.elevator},
    {'code': 'ADAPTED_BATHROOM', 'title': 'Banheiro Adaptado', 'icon': Icons.wc},
    {'code': 'MANEUVERING_SPACE', 'title': 'Espaço de Circulação e Manobra', 'icon': Icons.social_distance},
    {'code': 'ADAPTED_SEATING', 'title': 'Assentos e Mesas Acessíveis', 'icon': Icons.table_restaurant},
    {'code': 'ACCESSIBLE_PARKING', 'title': 'Vagas Reservadas', 'icon': Icons.local_parking},
    {'code': 'INCLUSIVE_SERVICE', 'title': 'Atendimento Inclusivo', 'icon': Icons.support_agent},
  ];

  bool _isSavingDraft = false;
  bool _hasPhotoAttached = false;

  @override
  void initState() {
    super.initState();
    context.read<ReviewsBloc>().add(LoadReviewDraftEvent(widget.placeId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _altTextController.dispose();
    super.dispose();
  }

  String _getRatingFeedback(int score) {
    switch (score) {
      case 1:
        return '1 - Inacessível';
      case 2:
        return '2 - Difícil acesso';
      case 3:
        return '3 - Parcialmente acessível';
      case 4:
        return '4 - Bom acesso';
      case 5:
        return '5 - Totalmente acessível';
      default:
        return '$score de 5';
    }
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
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_done, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Rascunho salvo offline com sucesso!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    setState(() => _isSavingDraft = false);
  }

  void _submitReview() {
    if (_hasPhotoAttached && _altTextController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warningOrange,
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Para anexar uma foto, a audiodescrição (alt_text) com pelo menos 5 caracteres é obrigatória!',
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 18),
              label: const Text(
                'Salvar Rascunho',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: _isSavingDraft ? null : _saveDraft,
            ),
          ),
        ],
      ),
      body: BlocListener<ReviewsBloc, ReviewsState>(
        listener: (context, state) {
          if (state is ReviewsLoaded && state.submitSuccess) {
            SemanticsHelper.announce('Avaliação publicada com sucesso');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Avaliação publicada com sucesso!'),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
              // Intro Guidance Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: AppColors.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Avaliação Cidadã de Acessibilidade',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Suas notas ajudam milhares de pessoas a se locomoverem com autonomia e segurança.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Semantics(
                header: true,
                child: Text(
                  'Notas de Acessibilidade (1 a 5)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Avalie os itens que você teve oportunidade de observar:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
              ),
              const SizedBox(height: 16),

              // 7 Criteria Rating Controls
              ..._criteriaList.map((crit) {
                final code = crit['code'] as String;
                final title = crit['title'] as String;
                final icon = crit['icon'] as IconData;
                final currentScore = _ratings[code] ?? 5;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 0.8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stars Rating Row
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
                                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                    size: 34,
                                    color: isSelected ? AppColors.starGold : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getRatingFeedback(currentScore),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // General Remarks
              AccessibleTextField(
                controller: _commentController,
                label: 'Comentários e Dicas de Acessibilidade (Opcional)',
                hint: 'Ex: A rampa é bem espaçosa, porém a porta do banheiro é pesada...',
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // Photo attachment with mandatory alt_text
              Semantics(
                header: true,
                child: Text(
                  'Comprovação Fotográfica (Opcional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                ),
              ),
              const SizedBox(height: 10),

              // Photo Upload Box
              InkWell(
                onTap: () {
                  setState(() => _hasPhotoAttached = !_hasPhotoAttached);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _hasPhotoAttached ? AppColors.successLight.withOpacity(0.4) : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _hasPhotoAttached ? AppColors.successGreen : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasPhotoAttached ? Icons.check_circle_rounded : Icons.add_a_photo_rounded,
                        color: _hasPhotoAttached ? AppColors.successGreen : AppColors.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _hasPhotoAttached ? 'Foto Anexada ✓ (Toque para remover)' : 'Anexar Foto do Local',
                        style: TextStyle(
                          color: _hasPhotoAttached ? AppColors.successGreen : AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_hasPhotoAttached) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.starGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'A audiodescrição (alt_text) garante que pessoas com deficiência visual possam compreender o que está visível na foto.',
                          style: TextStyle(fontSize: 12, color: Colors.brown.shade800, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AccessibleTextField(
                  controller: _altTextController,
                  label: 'Audiodescrição Obrigatória da Foto (alt_text)',
                  hint: 'Descreva os elementos de acessibilidade visíveis na foto para quem usa leitor de tela',
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              BlocBuilder<ReviewsBloc, ReviewsState>(
                builder: (context, state) {
                  return AccessibleButton(
                    label: 'Publicar Avaliação',
                    icon: Icons.send_rounded,
                    isLoading: state is ReviewsLoading,
                    onPressed: _submitReview,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
