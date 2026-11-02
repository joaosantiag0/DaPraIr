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
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  place.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),

                // Overall score and outdated badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            place.overallScore.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${place.totalReviews} ${place.totalReviews == 1 ? "avaliação" : "avaliações"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                if (place.isOutdated) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.warningOrange, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warningOrange, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Última avaliação realizada há mais de 12 meses. As condições de acessibilidade podem ter sofrido alterações.',
                            style: TextStyle(
                              color: AppColors.warningOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Route & Review Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AccessibleButton(
                        label: 'Como Chegar',
                        icon: Icons.directions,
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
                        icon: Icons.rate_review,
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

                const SizedBox(height: 24),

                // Criteria Breakdown Header
                Semantics(
                  header: true,
                  child: Text(
                    'Avaliação por Critério de Acessibilidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // 7 Standard Criteria
                ...place.criteriaBreakdown.map((crit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AccessibleCard(
                      padding: const EdgeInsets.all(12.0),
                      semanticLabel: SemanticsHelper.formatCriterionAnnouncement(
                        crit.title,
                        crit.averageScore.round(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  crit.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Text(
                                crit.ratingsCount > 0 ? '${crit.averageScore.toStringAsFixed(1)} / 5.0' : 'Sem nota',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: crit.ratingsCount > 0 ? (crit.averageScore / 5.0) : 0,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                crit.averageScore >= 4.0
                                    ? AppColors.successGreen
                                    : (crit.averageScore >= 2.5 ? Colors.amber.shade800 : AppColors.warningOrange),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Reviews Section
                Semantics(
                  header: true,
                  child: Text(
                    'Avaliações da Comunidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                BlocBuilder<ReviewsBloc, ReviewsState>(
                  builder: (context, rState) {
                    if (rState is ReviewsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (rState is ReviewsLoaded) {
                      if (rState.reviews.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('Nenhuma avaliação cadastrada ainda. Seja o primeiro a avaliar!'),
                        );
                      }

                      return Column(
                        children: rState.reviews.map((rev) {
                          return AccessibleCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      rev.author.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (rev.isUnderReview)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.underReviewYellow.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Sob análise',
                                          style: TextStyle(
                                            color: AppColors.underReviewYellow,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (rev.generalComment != null && rev.generalComment!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(rev.generalComment!),
                                ],
                                if (rev.media.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  // Audiodescribed media display
                                  ...rev.media.map((m) => Semantics(
                                        image: true,
                                        label: 'Foto: ${m.altText}',
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.photo_outlined, size: 24),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Foto: ${m.altText}',
                                                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ],
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
