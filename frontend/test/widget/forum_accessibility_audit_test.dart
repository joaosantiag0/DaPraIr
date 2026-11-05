import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/forum_category.dart';
import 'package:frontend/domain/entities/forum_topic.dart';
import 'package:frontend/presentation/components/forum_category_card.dart';
import 'package:frontend/presentation/components/forum_topic_tile.dart';
import 'package:frontend/presentation/components/subthread_collapse_toggle.dart';
import 'package:frontend/presentation/components/visibility_badge.dart';

void main() {
  group('Comprehensive WCAG 2.1 AA Accessibility Audit', () {
    testWidgets('VisibilityBadge provides descriptive TalkBack/VoiceOver semantics label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                VisibilityBadge(visibility: 'PUBLIC'),
                VisibilityBadge(visibility: 'COMMUNITY'),
                VisibilityBadge(visibility: 'AUTHOR'),
              ],
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Visibilidade: Pública (aberto a visitantes anônimos e indexação)'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Visibilidade: Comunidade (restrito a usuários autenticados)'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Visibilidade: Privado (visível apenas para você e o autor)'),
        findsOneWidget,
      );
    });

    testWidgets('SubthreadCollapseToggle complies with >= 48x48 dp target and button semantics',
        (WidgetTester tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubthreadCollapseToggle(
              isCollapsed: false,
              repliesCount: 4,
              onTap: () => toggled = true,
            ),
          ),
        ),
      );

      final toggleFinder = find.byType(SubthreadCollapseToggle);
      final size = tester.getSize(toggleFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));

      expect(
        tester.getSemantics(toggleFinder),
        matchesSemantics(
          isButton: true,
          hasTapAction: true,
          label: 'Recolher 4 respostas nesta subthread',
        ),
      );

      await tester.tap(toggleFinder);
      expect(toggled, true);
    });

    testWidgets('ForumCategoryCard has minimum touch target >= 48x48 dp and button semantics',
        (WidgetTester tester) async {
      const cat = ForumCategory(
        id: 'cat-audit-1',
        name: 'Tecnologia Assistiva',
        slug: 'tecnologia-assistiva',
        description: 'Softwares e hardwares acessíveis',
        iconName: 'devices',
        displayOrder: 1,
        isActive: true,
        topicsCount: 9,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForumCategoryCard(
              category: cat,
              onTap: () {},
            ),
          ),
        ),
      );

      final cardFinder = find.byType(ForumCategoryCard);
      final size = tester.getSize(cardFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));

      expect(
        tester.getSemantics(cardFinder),
        matchesSemantics(
          isButton: true,
          hasTapAction: true,
          label: 'Categoria Tecnologia Assistiva, 9 tópicos. Toque para ver discussões.',
        ),
      );
    });

    testWidgets('ForumTopicTile complies with touch target >= 48x48 dp and interactive semantics',
        (WidgetTester tester) async {
      final topic = ForumTopic(
        id: 'top-audit-1',
        categoryId: 'cat-audit-1',
        categoryName: 'Tecnologia Assistiva',
        authorId: 'user-audit-1',
        author: const ForumAuthor(id: 'user-audit-1', name: 'Leandro', handle: 'leandro'),
        title: 'Leitores de tela para Linux',
        content: 'Comparativo entre Orca e outras ferramentas livres.',
        visibility: 'PUBLIC',
        status: 'ACTIVE',
        isEdited: false,
        likesCount: 7,
        commentsCount: 3,
        isLikedByMe: false,
        createdAt: DateTime(2026, 11, 4),
        updatedAt: DateTime(2026, 11, 4),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForumTopicTile(
              topic: topic,
              onTap: () {},
              onLikeTap: () {},
            ),
          ),
        ),
      );

      final tileFinder = find.byType(ForumTopicTile);
      final size = tester.getSize(tileFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));

      expect(
        tester.getSemantics(tileFinder),
        matchesSemantics(
          isButton: true,
          hasTapAction: true,
          label:
              'Tópico: Leitores de tela para Linux. Categoria: Tecnologia Assistiva. Autor: Leandro (@leandro). 7 curtidas, 3 comentários. Toque para abrir debate.',
        ),
      );
    });
  });
}
