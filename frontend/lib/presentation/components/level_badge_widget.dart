import 'package:flutter/material.dart';

class LevelBadgeWidget extends StatelessWidget {
  final String levelName;
  final String? levelId;
  final bool compact;

  const LevelBadgeWidget({
    super.key,
    required this.levelName,
    this.levelId,
    this.compact = false,
  });

  Color _getLevelColor(BuildContext context) {
    switch (levelId?.toUpperCase()) {
      case 'AMBASSADOR':
        return Colors.purple.shade700;
      case 'SPECIALIST':
        return Colors.indigo.shade700;
      case 'MAPPER':
        return Colors.teal.shade800;
      case 'COLLABORATOR':
        return Colors.blue.shade800;
      case 'EXPLORER':
      default:
        return Colors.green.shade800;
    }
  }

  IconData _getLevelIcon() {
    switch (levelId?.toUpperCase()) {
      case 'AMBASSADOR':
        return Icons.military_tech;
      case 'SPECIALIST':
        return Icons.workspace_premium;
      case 'MAPPER':
        return Icons.map;
      case 'COLLABORATOR':
        return Icons.volunteer_activism;
      case 'EXPLORER':
      default:
        return Icons.explore;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getLevelColor(context);

    return Semantics(
      label: 'Nível comunitário: $levelName',
      container: true,
      child: Container(
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: badgeColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getLevelIcon(),
              size: compact ? 14 : 18,
              color: badgeColor,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                levelName,
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
