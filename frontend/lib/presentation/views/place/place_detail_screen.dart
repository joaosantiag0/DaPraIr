import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/places/places_bloc.dart';
import '../../bloc/reviews/reviews_bloc.dart';
import '../../../domain/entities/place.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/navigation/external_navigation_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_card.dart';
import '../../components/guest_action_dialog.dart';
import 'submit_review_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  final Place? initialPlace;
  final bool isAuthenticated;
  final VoidCallback? onNavigateToLogin;

  const PlaceDetailScreen({
    super.key,
    required this.placeId,
    this.initialPlace,
    this.isAuthenticated = false,
    this.onNavigateToLogin,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlacesBloc>().add(LoadPlaceDetailsEvent(widget.placeId));
    context.read<ReviewsBloc>().add(LoadReviewsEvent(widget.placeId));
  }

  IconData _getCriterionIcon(String criterionCode) {
    switch (criterionCode.toUpperCase()) {
      case 'ENTRANCE_RAMP_LEVEL':
        return Icons.accessible_forward;
      case 'ELEVATOR_LIFT':
        return Icons.elevator;
      case 'ADAPTED_BATHROOM':
        return Icons.wc;
      case 'MANEUVERING_SPACE':
        return Icons.social_distance;
      case 'ADAPTED_SEATING':
        return Icons.table_restaurant;
      case 'ACCESSIBLE_PARKING':
        return Icons.local_parking;
      case 'INCLUSIVE_SERVICE':
        return Icons.support_agent;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _getQualityLabel(double score) {
    if (score >= 4.5) return 'Excelente Acessibilidade';
    if (score >= 3.5) return 'Boa Acessibilidade';
    if (score >= 2.5) return 'Acessibilidade Regular';
    return 'Acessibilidade Limitada';
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return AppColors.successGreen;
    if (score >= 2.5) return AppColors.starGold;
    return AppColors.warningOrange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes de Acessibilidade'),
      ),
      body: BlocBuilder<PlacesBloc, PlacesState>(
        builder: (context, state) {
          final place = (state is PlacesLoaded && state.selectedPlace?.id == widget.placeId)
              ? state.selectedPlace!
              : widget.initialPlace;

          if (place == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando informações de acessibilidade...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.category,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Place Name & Address
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textHint,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Overall Score Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Big Score Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                                const SizedBox(width: 4),
                                Text(
                                  place.overallScore.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'de 5.0',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getQualityLabel(place.overallScore),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${place.totalReviews} ${place.totalReviews == 1 ? "avaliação da comunidade" : "avaliações da comunidade"}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Outdated Review Alert Banner (12 months rule)
                if (place.isOutdated) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warningOrange.withOpacity(0.6), width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.schedule_rounded, color: AppColors.warningOrange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aviso de Atualização',
                                style: TextStyle(
                                  color: AppColors.warningOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Última avaliação realizada há mais de 12 meses. As condições de acessibilidade podem ter sofrido alterações.',
                                style: TextStyle(
                                  color: AppColors.warningOrange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action Buttons: Route & Review
                Row(
                  children: [
                    Expanded(
                      child: AccessibleButton(
                        label: 'Como Chegar',
                        icon: Icons.directions_rounded,
                        onPressed: () {
                          ExternalNavigationLauncher.showNavigationPicker(
                            context: context,
                            latitude: place.latitude,
                            longitude: place.longitude,
                            destinationName: place.name,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AccessibleButton(
                        label: 'Avaliar Local',
                        icon: Icons.rate_review_rounded,
                        isSecondary: true,
                        onPressed: () {
                          if (!widget.isAuthenticated) {
                            GuestActionDialog.show(
                              context: context,
                              actionTitle: 'avaliar as condições deste local',
                              onLoginPressed: widget.onNavigateToLogin ?? () {},
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubmitReviewScreen(placeId: place.id),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Criteria Breakdown Header
                Semantics(
                  header: true,
                  child: Text(
                    'Avaliação por Critério de Acessibilidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // 7 Standard Criteria
                ...place.criteriaBreakdown.map((crit) {
                  final scoreColor = _getScoreColor(crit.averageScore);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: AccessibleCard(
                      padding: const EdgeInsets.all(14.0),
                      semanticLabel: SemanticsHelper.formatCriterionAnnouncement(
                        crit.title,
                        crit.averageScore.round(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getCriterionIcon(crit.code),
                                  size: 18,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  crit.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: crit.ratingsCount > 0 ? AppColors.surfaceMuted : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  crit.ratingsCount > 0 ? '${crit.averageScore.toStringAsFixed(1)} / 5.0' : 'Sem nota',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: crit.ratingsCount > 0 ? scoreColor : AppColors.textHint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: crit.ratingsCount > 0 ? (crit.averageScore / 5.0) : 0,
                              minHeight: 8,
                              backgroundColor: AppColors.surfaceMuted,
                              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Reviews Section
                Semantics(
                  header: true,
                  child: Text(
                    'Avaliações da Comunidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                BlocBuilder<ReviewsBloc, ReviewsState>(
                  builder: (context, rState) {
                    if (rState is ReviewsLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (rState is ReviewsLoaded) {
                      if (rState.reviews.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.rate_review_outlined, size: 40, color: AppColors.textHint),
                              const SizedBox(height: 10),
                              const Text(
                                'Nenhuma avaliação cadastrada ainda. Seja o primeiro a avaliar!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: rState.reviews.map((rev) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: AccessibleCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.primaryContainer,
                                        child: Text(
                                          rev.author.name.isNotEmpty ? rev.author.name[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          rev.author.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      if (rev.isUnderReview)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.underReviewLight,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.underReviewYellow),
                                          ),
                                          child: const Text(
                                            'Sob análise',
                                            style: TextStyle(
                                              color: AppColors.underReviewYellow,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (rev.generalComment != null && rev.generalComment!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        rev.generalComment!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
                                      ),
                                    ),
                                  ],
                                  if (rev.media.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    ...rev.media.map((m) => Semantics(
                                          image: true,
                                          label: 'Foto: ${m.altText}',
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 6),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryContainer.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.borderLight),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.photo_camera_rounded, size: 22, color: AppColors.primaryBlue),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Foto: ${m.altText}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontStyle: FontStyle.italic,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
