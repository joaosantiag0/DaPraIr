import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/feed/feed_bloc.dart';
import '../../../domain/entities/feed_item.dart';
import '../../components/accessible_button.dart';
import '../../components/content_report_dialog.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const LoadFeedRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DáPraIr?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar feed',
            onPressed: () {
              context.read<FeedBloc>().add(const RefreshFeedRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state.reportMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.reportMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FeedStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FeedStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro ao carregar feed: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  AccessibleButton(
                    label: 'Tentar novamente',
                    onPressed: () => context.read<FeedBloc>().add(const LoadFeedRequested()),
                  ),
                ],
              ),
            );
          }

          final feedData = state.feedData;
          if (feedData == null) {
            return const Center(child: Text('Nenhum dado disponível no momento.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FeedBloc>().add(const RefreshFeedRequested());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // 1. Highlighted Places Section
                if (feedData.highlightedPlaces.isNotEmpty) ...[
                  _SectionHeader(title: 'Locais Acessíveis em Destaque', icon: Icons.star),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: feedData.highlightedPlaces.length,
                      itemBuilder: (context, index) {
                        final place = feedData.highlightedPlaces[index];
                        return _HighlightedPlaceCard(place: place);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 2. Upcoming Inclusive Events Section
                if (feedData.upcomingEvents.isNotEmpty) ...[
                  _SectionHeader(title: 'Próximos Eventos Inclusivos', icon: Icons.event),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: feedData.upcomingEvents.length,
                    itemBuilder: (context, index) {
                      final event = feedData.upcomingEvents[index];
                      return _FeedEventCard(event: event);
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 3. Recent Reviews Section
                if (feedData.recentReviews.isNotEmpty) ...[
                  _SectionHeader(title: 'Últimas Avaliações da Comunidade', icon: Icons.rate_review),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: feedData.recentReviews.length,
                    itemBuilder: (context, index) {
                      final review = feedData.recentReviews[index];
                      return _RecentReviewCard(
                        review: review,
                        onReport: () {
                          ContentReportDialog.show(
                            context: context,
                            targetType: 'REVIEW',
                            targetId: review.id,
                            onSubmit: (reason, details) {
                              context.read<FeedBloc>().add(
                                    SubmitReportRequested(
                                      targetType: 'REVIEW',
                                      targetId: review.id,
                                      reason: reason,
                                      details: details,
                                    ),
                                  );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 4. Accessibility Tips Section
                if (feedData.accessibilityTips.isNotEmpty) ...[
                  _SectionHeader(title: 'Dicas de Acessibilidade & Normas', icon: Icons.lightbulb),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: feedData.accessibilityTips.length,
                    itemBuilder: (context, index) {
                      final tip = feedData.accessibilityTips[index];
                      return _TipCard(tip: tip);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedPlaceCard extends StatelessWidget {
  final HighlightedPlace place;

  const _HighlightedPlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Local: ${place.name}, Nota: ${place.overallScore.toStringAsFixed(1)}, Categoria: ${place.category}',
      button: true,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        place.category,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          place.overallScore.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  place.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentReviewCard extends StatelessWidget {
  final RecentFeedReview review;
  final VoidCallback onReport;

  const _RecentReviewCard({required this.review, required this.onReport});

  @override
  Widget build(BuildContext context) {
    final isUnderReview = review.status == 'UNDER_REVIEW';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Under review warning banner
            if (isUnderReview)
              Semantics(
                label: 'Aviso: Avaliação sob análise por denúncia de conteúdo',
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 6),
                      Text(
                        'Sob análise da moderação',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.placeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Por ${review.authorName} (${review.authorHandle})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      review.averageScore.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.flag_outlined, size: 20),
                      tooltip: 'Denunciar esta avaliação',
                      onPressed: onReport,
                    ),
                  ],
                ),
              ],
            ),
            if (review.generalComment != null && review.generalComment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.generalComment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedEventCard extends StatelessWidget {
  final FeedEventSummary event;

  const _FeedEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.locationName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  '${event.rsvpCount} confirmados',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final AccessibilityTip tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              tip.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
