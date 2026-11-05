import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/places/places_bloc.dart';
import '../../bloc/reviews/reviews_bloc.dart';
import '../auth/login_screen.dart';
import '../../../domain/entities/place.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/navigation/external_navigation_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_card.dart';
import '../../components/guest_action_dialog.dart';
import '../../components/responsive_container.dart';
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
  bool get _isAuthenticated {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) return true;
    } catch (_) {}
    return widget.isAuthenticated;
  }

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

  void _openFullScreenImage(BuildContext context, String imageUrl, String altText) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.92),
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.white70, size: 48),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                tooltip: 'Fechar imagem ampliada',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            if (altText.isNotEmpty)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    altText,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
            child: ResponsiveContainer.medium(
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
                          color: place.totalReviews > 0 ? AppColors.primaryBlue : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                          border: place.totalReviews == 0 ? Border.all(color: AppColors.primaryBlue.withOpacity(0.3)) : null,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  place.totalReviews > 0 ? Icons.star_rounded : Icons.travel_explore_rounded,
                                  color: place.totalReviews > 0 ? Colors.amber : AppColors.primaryBlue,
                                  size: 24,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  place.totalReviews > 0 ? place.overallScore.toStringAsFixed(1) : 'Novo',
                                  style: TextStyle(
                                    color: place.totalReviews > 0 ? Colors.white : AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: place.totalReviews > 0 ? 22 : 18,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              place.totalReviews > 0 ? 'de 5.0' : 'Novo Local',
                              style: TextStyle(
                                color: place.totalReviews > 0 ? Colors.white70 : AppColors.primaryBlue.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
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
                              place.totalReviews > 0 ? _getQualityLabel(place.overallScore) : 'Aguardando 1ª Avaliação',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place.totalReviews > 0
                                  ? '${place.totalReviews} ${place.totalReviews == 1 ? "avaliação da comunidade" : "avaliações da comunidade"}'
                                  : 'Novo estabelecimento • Seja o primeiro a avaliar a acessibilidade deste local!',
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
                          if (!_isAuthenticated) {
                            GuestActionDialog.show(
                              context: context,
                              actionTitle: 'avaliar as condições deste local',
                              onLoginPressed: () async {
                                final loggedIn = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                                if (context.mounted && (loggedIn == true || _isAuthenticated)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubmitReviewScreen(placeId: place.id),
                                    ),
                                  );
                                }
                              },
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
                                    ...rev.media.map((m) {
                                      final targetUrl = m.mediaUrl.isNotEmpty ? m.mediaUrl : (m.thumbnailUrl ?? '');
                                      return Semantics(
                                        image: true,
                                        label: 'Foto do local: ${m.altText}. Toque para ampliar.',
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceMuted,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.borderLight),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: targetUrl.isNotEmpty
                                                ? () => _openFullScreenImage(context, targetUrl, m.altText)
                                                : null,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                if (targetUrl.isNotEmpty &&
                                                    (targetUrl.startsWith('http') || targetUrl.startsWith('blob:')))
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        constraints: const BoxConstraints(
                                                          minHeight: 140,
                                                          maxHeight: 340,
                                                        ),
                                                        color: Colors.black.withOpacity(0.04),
                                                        alignment: Alignment.center,
                                                        child: Image.network(
                                                          targetUrl,
                                                          fit: BoxFit.contain,
                                                          width: double.infinity,
                                                          errorBuilder: (context, error, stackTrace) => Container(
                                                            height: 100,
                                                            color: AppColors.surfaceMuted,
                                                            child: const Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Icon(Icons.broken_image_rounded,
                                                                      color: AppColors.textSecondary, size: 28),
                                                                  SizedBox(height: 4),
                                                                  Text(
                                                                    'Imagem não pôde ser carregada',
                                                                    style: TextStyle(
                                                                        fontSize: 12, color: AppColors.textSecondary),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 8,
                                                        right: 8,
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.65),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: const Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                                              SizedBox(width: 4),
                                                              Text(
                                                                'Ampliar',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.photo_camera_rounded,
                                                          size: 18, color: AppColors.primaryBlue),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          'Audiodescrição: ${m.altText}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontStyle: FontStyle.italic,
                                                            color: AppColors.textPrimary,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
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
          ),
        );
      },
      ),
    );
  }
}
