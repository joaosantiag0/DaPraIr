import 'package:flutter/material.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'level_badge_widget.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  Widget _buildRankBadge(BuildContext context) {
    Color rankColor;
    IconData? rankIcon;

    if (entry.rank == 1) {
      rankColor = const Color(0xFFD4AF37); // Ouro escuro com contraste
      rankIcon = Icons.emoji_events;
    } else if (entry.rank == 2) {
      rankColor = const Color(0xFF757575); // Prata escura
      rankIcon = Icons.military_tech;
    } else if (entry.rank == 3) {
      rankColor = const Color(0xFF8D5B4C); // Bronze escuro
      rankIcon = Icons.workspace_premium;
    } else {
      rankColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rankColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: rankColor, width: 1.5),
      ),
      child: rankIcon != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(rankIcon, size: 16, color: rankColor),
                Text(
                  '${entry.rank}º',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ],
            )
          : Text(
              '${entry.rank}º',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${entry.rank}º colocado, ${entry.displayName}, ${entry.points} pontos, nível ${entry.levelName}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCurrentUser
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildRankBadge(context),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage:
                    entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
                child: entry.avatarUrl == null
                    ? const Icon(Icons.person, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    LevelBadgeWidget(
                      levelName: entry.levelName,
                      levelId: entry.levelId,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.points}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Text(
                    'pts',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
