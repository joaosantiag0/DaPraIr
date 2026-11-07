import 'package:flutter/material.dart';

class RankingPeriodTabs extends StatelessWidget {
  final String activePeriod;
  final ValueChanged<String> onPeriodChanged;

  const RankingPeriodTabs({
    super.key,
    required this.activePeriod,
    required this.onPeriodChanged,
  });

  Widget _buildTab(BuildContext context, String periodKey, String label) {
    final isSelected = activePeriod == periodKey;
    final theme = Theme.of(context);

    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: 'Aba de ranking $label',
        child: InkWell(
          onTap: () => onPeriodChanged(periodKey),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48), // WCAG 48x48
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(context, 'weekly', 'Semanal'),
          const SizedBox(width: 6),
          _buildTab(context, 'monthly', 'Mensal'),
          const SizedBox(width: 6),
          _buildTab(context, 'all_time', 'Geral'),
        ],
      ),
    );
  }
}
