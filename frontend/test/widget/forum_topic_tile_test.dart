import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/forum_category.dart';
import 'package:frontend/domain/entities/forum_topic.dart';
import 'package:frontend/presentation/components/forum_category_card.dart';
import 'package:frontend/presentation/components/forum_topic_tile.dart';

void main() {
  const testCategory = ForumCategory(
    id: 'cat-1',
    name: 'Mobilidade Urbana',
    slug: 'mobilidade-urbana',
    description: 'Debates sobre transporte',
    iconName: 'directions_bus',
    displayOrder: 1,
    isActive: true,
    topicsCount: 12,
  );

  final testTopic = ForumTopic(
    id: 'topic-1',
    categoryId: 'cat-1',
    categoryName: 'Mobilidade Urbana',
    authorId: 'user-1',
    author: const ForumAuthor(id: 'user-1', name: 'Juliana Mendes', handle: 'ju_mendes'),
    title: 'Acessibilidade em ônibus elétricos',
    content: 'Discussão sobre rampas de acesso',
    visibility: 'PUBLIC',
    status: 'ACTIVE',
    isEdited: false,
    likesCount: 15,
    commentsCount: 8,
    isLikedByMe: false,
    createdAt: DateTime(2026, 11, 4),
    updatedAt: DateTime(2026, 11, 4),
  );

  group('Forum Accessibility and Widget Tests (WCAG 2.1 AA)', () {
    testWidgets('ForumTopicTile renders accessible semantics and min touch target >= 48x48 dp',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForumTopicTile(
              topic: testTopic,
              onTap: () => tapped = true,
              onLikeTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Acessibilidade em ônibus elétricos'), findsOneWidget);
      expect(find.text('Juliana Mendes (@ju_mendes)'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);

      // Verify touch target size
      final tileFinder = find.byType(ForumTopicTile);
      final size = tester.getSize(tileFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));

      // Verify tap works
      await tester.tap(tileFinder);
      expect(tapped, true);

      // Verify Semantics
      expect(
        tester.getSemantics(tileFinder),
        matchesSemantics(
          isButton: true,
          hasTapAction: true,
          label:
              'Tópico: Acessibilidade em ônibus elétricos. Categoria: Mobilidade Urbana. Autor: Juliana Mendes (@ju_mendes). 15 curtidas, 8 comentários. Toque para abrir debate.',
        ),
      );
    });

    testWidgets('ForumCategoryCard renders accessible semantics and min touch target >= 48x48 dp',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForumCategoryCard(
              category: testCategory,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Mobilidade Urbana'), findsOneWidget);
      expect(find.text('12 tópicos'), findsOneWidget);

      final cardFinder = find.byType(ForumCategoryCard);
      final size = tester.getSize(cardFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));

      await tester.tap(cardFinder);
      expect(tapped, true);

      expect(
        tester.getSemantics(cardFinder),
        matchesSemantics(
          isButton: true,
          hasTapAction: true,
          label: 'Categoria Mobilidade Urbana, 12 tópicos. Toque para ver discussões.',
        ),
      );
    });
  });
}
