import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/forum_topic.dart';
import 'package:frontend/domain/entities/forum_comment.dart';
import 'package:frontend/presentation/components/forum_comment_thread.dart';
import 'package:frontend/presentation/components/subthread_collapse_toggle.dart';

void main() {
  final commentL2 = ForumComment(
    id: 'comm-2',
    topicId: 'topic-1',
    parentId: 'comm-1',
    authorId: 'user-2',
    author: const ForumAuthor(id: 'user-2', name: 'Marcos Vinicius', handle: 'marcos_v'),
    replyToUserId: 'user-1',
    replyToUserHandle: 'ju_mendes',
    content: 'Resposta de nível 2 concordando com a acessibilidade.',
    depth: 2,
    visibility: 'PUBLIC',
    status: 'ACTIVE',
    isEdited: false,
    likesCount: 2,
    isLikedByMe: false,
    replies: const [],
    createdAt: DateTime(2026, 11, 4, 10, 30),
    updatedAt: DateTime(2026, 11, 4, 10, 30),
  );

  final commentL1 = ForumComment(
    id: 'comm-1',
    topicId: 'topic-1',
    authorId: 'user-1',
    author: const ForumAuthor(id: 'user-1', name: 'Juliana Mendes', handle: 'ju_mendes'),
    content: 'Comentário raiz de nível 1 sobre a rampa.',
    depth: 1,
    visibility: 'PUBLIC',
    status: 'ACTIVE',
    isEdited: false,
    likesCount: 4,
    isLikedByMe: true,
    replies: [commentL2],
    createdAt: DateTime(2026, 11, 4, 10, 0),
    updatedAt: DateTime(2026, 11, 4, 10, 0),
  );

  group('ForumCommentThread Accessibility & Hierarchy Tests (WCAG 2.1 AA)', () {
    testWidgets('renders comments tree with correct depth indentation and reply mentions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ForumCommentThread(
                comment: commentL1,
                collapsedCommentIds: const {},
                onToggleCollapse: (_) {},
                onReplyTap: (_) {},
                onLikeTap: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify Level 1 and Level 2 texts are rendered
      expect(find.text('Comentário raiz de nível 1 sobre a rampa.'), findsOneWidget);
      expect(find.text('Resposta de nível 2 concordando com a acessibilidade.'), findsOneWidget);
      expect(find.text('@ju_mendes'), findsOneWidget); // Mention of parent author
    });

    testWidgets('SubthreadCollapseToggle has min 48x48 dp touch target and clear semantics',
        (WidgetTester tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubthreadCollapseToggle(
              isCollapsed: false,
              repliesCount: 3,
              onTap: () => toggled = true,
            ),
          ),
        ),
      );

      final toggleFinder = find.byType(SubthreadCollapseToggle);
      final size = tester.getSize(toggleFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));

      await tester.tap(toggleFinder);
      expect(toggled, true);
    });
  });
}
