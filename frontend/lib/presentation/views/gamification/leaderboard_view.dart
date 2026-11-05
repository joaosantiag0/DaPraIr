import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../bloc/gamification/gamification_event.dart';
import '../../bloc/gamification/gamification_state.dart';
import '../../components/leaderboard_tile.dart';
import '../../components/ranking_period_tabs.dart';
import '../../components/user_rank_sticky_bar.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  @override
  void initState() {
    super.initState();
    context.read<GamificationBloc>().add(const LoadLeaderboard(period: 'monthly'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Colaboradores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Privacidade no Ranking',
            onPressed: () {
              Navigator.of(context).pushNamed('/gamification/privacy');
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Meu Perfil de Pontos',
            onPressed: () {
              Navigator.of(context).pushNamed('/gamification/profile');
            },
          ),
        ],
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          final userRank = state.userRank;

          return Column(
            children: [
              RankingPeriodTabs(
                activePeriod: state.activePeriod,
                onPeriodChanged: (period) {
                  context.read<GamificationBloc>().add(LoadLeaderboard(period: period));
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<GamificationBloc>().add(
                          LoadLeaderboard(period: state.activePeriod),
                        );
                  },
                  child: state.status == GamificationStatus.loading &&
                          state.leaderboard.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.leaderboard.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_events_outlined,
                                      size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Nenhuma contribuição neste período ainda.',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Seja o primeiro a avaliar um local e pontuar!',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.leaderboard.length,
                              itemBuilder: (context, index) {
                                final entry = state.leaderboard[index];
                                final isMe = userRank != null &&
                                    entry.rank == userRank['rank'];

                                return LeaderboardTile(
                                  entry: entry,
                                  isCurrentUser: isMe,
                                );
                              },
                            ),
                ),
              ),
              if (userRank != null && userRank['rank'] != null)
                UserRankStickyBar(
                  rank: userRank['rank'] as int,
                  points: userRank['points'] as int? ?? 0,
                  nextRankPointsDiff:
                      userRank['next_rank_points_diff'] as int? ?? 0,
                ),
            ],
          );
        },
      ),
    );
  }
}
