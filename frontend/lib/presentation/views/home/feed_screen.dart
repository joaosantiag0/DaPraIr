import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/feed/feed_bloc.dart';
import '../../../domain/entities/feed_item.dart';
import '../../../domain/entities/event.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/content_report_dialog.dart';
import '../../components/responsive_container.dart';
import '../place/place_detail_screen.dart';
import '../events/event_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedCategory = 'TODOS';

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const LoadFeedRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.accessible_forward, size: 26),
            SizedBox(width: 8),
            Text(
              'DáPraIr?',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ],
        ),
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
              SnackBar(
                content: Text(state.reportMessage!),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FeedStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Carregando novidades da comunidade...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          if (state.status == FeedStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.warningLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, size: 48, color: AppColors.warningOrange),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar feed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Ocorreu um problema ao conectar com a comunidade.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    AccessibleButton(
                      label: 'Tentar novamente',
                      icon: Icons.refresh,
                      onPressed: () => context.read<FeedBloc>().add(const LoadFeedRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          final feedData = state.feedData;
          if (feedData == null) {
            return const Center(
              child: Text(
                'Nenhum dado disponível no momento.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final filteredPlaces = _selectedCategory == 'TODOS'
              ? feedData.highlightedPlaces
              : feedData.highlightedPlaces.where((p) => p.category.toUpperCase() == _selectedCategory).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FeedBloc>().add(const RefreshFeedRequested());
            },
            child: ResponsiveContainer.wide(
              child: ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 28),
              children: [
                // Welcome Hero Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.place, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Acessibilidade Urbana Colaborativa',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Descubra onde dá pra ir sem barreiras',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Locais auditados, rotas acessíveis e eventos inclusivos verificados por pessoas com deficiência física e mobilidade reduzida.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Category Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _CategoryFilterChip(
                        label: 'Todos',
                        icon: Icons.all_inclusive,
                        isSelected: _selectedCategory == 'TODOS',
                        onSelected: () => setState(() => _selectedCategory = 'TODOS'),
                      ),
                      _CategoryFilterChip(
                        label: 'Museus',
                        icon: Icons.museum,
                        isSelected: _selectedCategory == 'MUSEUM',
                        onSelected: () => setState(() => _selectedCategory = 'MUSEUM'),
                      ),
                      _CategoryFilterChip(
                        label: 'Parques',
                        icon: Icons.park,
                        isSelected: _selectedCategory == 'PARK',
                        onSelected: () => setState(() => _selectedCategory = 'PARK'),
                      ),
                      _CategoryFilterChip(
                        label: 'Teatros',
                        icon: Icons.theater_comedy,
                        isSelected: _selectedCategory == 'THEATER',
                        onSelected: () => setState(() => _selectedCategory = 'THEATER'),
                      ),
                      _CategoryFilterChip(
                        label: 'Restaurantes',
                        icon: Icons.restaurant,
                        isSelected: _selectedCategory == 'RESTAURANT',
                        onSelected: () => setState(() => _selectedCategory = 'RESTAURANT'),
                      ),
                      _CategoryFilterChip(
                        label: 'Lojas',
                        icon: Icons.shopping_bag,
                        isSelected: _selectedCategory == 'STORE',
                        onSelected: () => setState(() => _selectedCategory = 'STORE'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 1. Highlighted Places Section
                if (feedData.highlightedPlaces.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Locais Acessíveis em Destaque',
                    icon: Icons.star_rounded,
                    subtitle: '${feedData.highlightedPlaces.length} locais auditados com as melhores notas',
                  ),
                  SizedBox(
                    height: 178,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPlaces.isNotEmpty ? filteredPlaces.length : feedData.highlightedPlaces.length,
                      itemBuilder: (context, index) {
                        final place = filteredPlaces.isNotEmpty
                            ? filteredPlaces[index]
                            : feedData.highlightedPlaces[index];
                        return _HighlightedPlaceCard(place: place);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 2. Upcoming Inclusive Events Section
                if (feedData.upcomingEvents.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Próximos Eventos Inclusivos',
                    icon: Icons.event_available_rounded,
                    subtitle: 'Encontros com checklist de acessibilidade física verificado',
                  ),
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
                  _SectionHeader(
                    title: 'Últimas Avaliações da Comunidade',
                    icon: Icons.rate_review_rounded,
                    subtitle: 'Relatos de quem esteve no local e fotos com audiodescrição',
                  ),
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

                // 4. Accessibility Tips Section (Laws, NBR 9050, Guidelines)
                if (feedData.accessibilityTips.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Dicas de Acessibilidade & Normas',
                    icon: Icons.lightbulb_rounded,
                    subtitle: 'Guia prático da NBR 9050 e Lei Brasileira de Inclusão',
                  ),
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
                ],
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primaryContainer,
        checkmarkColor: AppColors.primaryBlue,
        backgroundColor: AppColors.surfaceLight,
        side: BorderSide(
          color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
          width: isSelected ? 1.5 : 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
              ),
            ),
          ],
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
        width: 230,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight, width: 1.2),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaceDetailScreen(placeId: place.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.starGold, size: 16),
                            const SizedBox(width: 3),
                            Text(
                              place.overallScore.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textHint,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight, width: 1.2),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailScreen(placeId: review.placeId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.underReviewLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.underReviewYellow, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.underReviewYellow),
                        const SizedBox(width: 8),
                        Text(
                          'Sob análise da moderação',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.underReviewYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      review.authorName.isNotEmpty ? review.authorName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.placeName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Por ${review.authorName} (${review.authorHandle})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textHint,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.starGold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          review.averageScore.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, size: 20, color: AppColors.textHint),
                    tooltip: 'Denunciar esta avaliação',
                    onPressed: onReport,
                  ),
                ],
              ),
              if (review.generalComment != null && review.generalComment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    review.generalComment!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ],
          ),
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
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight, width: 1.2),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                event: EventItem(
                  id: event.id,
                  title: event.title,
                  description: event.description,
                  startTime: event.startTime,
                  endTime: event.endTime,
                  locationName: event.locationName,
                  address: event.address,
                  accessibilityChecklist: const {
                    'rampa_acesso': true,
                    'banheiro_adaptado': true,
                    'elevador': true,
                  },
                  status: 'SCHEDULED',
                  rsvpCount: event.rsvpCount,
                  isAttending: event.isAttending,
                  organizer: EventOrganizer(
                    id: 'org',
                    name: event.organizerName,
                    handle: 'organizador',
                  ),
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar icon badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month, color: AppColors.accentTeal, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textHint,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${event.rsvpCount} confirmados',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
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
  }
}

class _TipCard extends StatelessWidget {
  final AccessibilityTip tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surfaceMuted,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderLight, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb, color: AppColors.starGold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
