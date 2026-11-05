import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../bloc/gamification/gamification_event.dart';
import '../../bloc/gamification/gamification_state.dart';
import '../../components/level_badge_widget.dart';

class GamificationProfileView extends StatefulWidget {
  const GamificationProfileView({super.key});

  @override
  State<GamificationProfileView> createState() => _GamificationProfileViewState();
}

class _GamificationProfileViewState extends State<GamificationProfileView> {
  @override
  void initState() {
    super.initState();
    context.read<GamificationBloc>().add(LoadGamificationProfile());
    context.read<GamificationBloc>().add(const LoadTransactionsHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Nível e Pontuação'),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          final profile = state.profile;

          if (state.status == GamificationStatus.loading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profile == null) {
            return const Center(child: Text('Não foi possível carregar o perfil de gamificação.'));
          }

          final currentLvl = profile.currentLevel;
          final nextLvl = profile.nextLevel;
          final progress = nextLvl != null && nextLvl.minPoints > currentLvl.minPoints
              ? ((profile.pointsTotal - currentLvl.minPoints) /
                      (nextLvl.minPoints - currentLvl.minPoints))
                  .clamp(0.0, 1.0)
              : 1.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      LevelBadgeWidget(
                        levelName: currentLvl.name,
                        levelId: currentLvl.id,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${profile.pointsTotal} Pontos Totais',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentLvl.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      if (nextLvl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faltam ${profile.pointsToNextLevel} pontos para ${nextLvl.name}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ] else ...[
                        const Text(
                          '🎉 Você atingiu o nível máximo da comunidade!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Extrato de Contribuições',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.read<GamificationBloc>().add(const LoadTransactionsHistory());
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Atualizar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('Nenhuma transação de pontos registrada ainda.'),
                  ),
                )
              else
                ...state.transactions.map((t) {
                  final isPositive = t.points > 0;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        isPositive ? Icons.add_circle : Icons.remove_circle,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 28,
                      ),
                      title: Text(t.description),
                      subtitle: Text(
                        '${t.createdAt.day.toString().padLeft(2, '0')}/${t.createdAt.month.toString().padLeft(2, '0')}/${t.createdAt.year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        '${isPositive ? '+' : ''}${t.points} pts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
