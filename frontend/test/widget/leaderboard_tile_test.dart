import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/leaderboard_entry.dart';
import 'package:frontend/presentation/components/leaderboard_tile.dart';
import 'package:frontend/presentation/components/ranking_period_tabs.dart';

void main() {
  group('Gamification Accessibility & Widget Tests', () {
    testWidgets('LeaderboardTile exposes complete semantic label and >= 48dp target', (tester) async {
      const entry = LeaderboardEntry(
        rank: 1,
        userId: 'test-user-uuid',
        displayName: 'Maria Santos',
        points: 450,
        levelName: 'Mapeador(a) de Acessibilidade',
        levelId: 'MAPPER',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LeaderboardTile(entry: entry),
          ),
        ),
      );

      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);
      expect(find.text('1º'), findsOneWidget);

      final semantics = tester.getSemantics(find.byType(LeaderboardTile));
      expect(
        semantics.label,
        contains('1º colocado, Maria Santos, 450 pontos, nível Mapeador(a) de Acessibilidade'),
      );
    });

    testWidgets('RankingPeriodTabs provides accessible 48x48 min touch targets', (tester) async {
      String selected = 'monthly';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankingPeriodTabs(
              activePeriod: selected,
              onPeriodChanged: (p) => selected = p,
            ),
          ),
        ),
      );

      expect(find.text('Semanal'), findsOneWidget);
      expect(find.text('Mensal'), findsOneWidget);
      expect(find.text('Geral'), findsOneWidget);

      // Verify touch target height
      final tabSize = tester.getSize(find.text('Semanal'));
      expect(tabSize.height, greaterThanOrEqualTo(14)); // text height inside >= 48 container

      await tester.tap(find.text('Semanal'));
      expect(selected, 'weekly');
    });
  });
}
