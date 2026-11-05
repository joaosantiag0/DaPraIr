import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/forum_comment.dart';
import 'package:frontend/domain/entities/forum_topic.dart';
import 'package:frontend/presentation/components/forum_comment_thread.dart';
import 'package:frontend/presentation/components/forum_topic_tile.dart';

void main() {
  group('Forum Moderation & LGPD Soft-Delete Tests (US4)', () {
    testWidgets('renders (editado) indicator when isEdited is true on topic and comment',
        (WidgetTester tester) async {
      final editedTopic = ForumTopic(
        id: 'top-mod-1',
        categoryId: 'cat-1',
        categoryName: 'Acessibilidade Geral',
        authorId: 'user-1',
        author: const ForumAuthor(id: 'user-1', name: 'Carlos', handle: 'carlos'),
        title: 'Tópico Editado',
        content: 'Conteúdo atualizado pelo autor.',
        visibility: 'PUBLIC',
        status: 'ACTIVE',
        isEdited: true,
        editedAt: DateTime(2026, 11, 4),
        likesCount: 2,
        commentsCount: 1,
        isLikedByMe: false,
        createdAt: DateTime(2026, 11, 4),
        updatedAt: DateTime(2026, 11, 4),
      );

      final editedComment = ForumComment(
        id: 'com-mod-1',
        topicId: 'top-mod-1',
        authorId: 'user-1',
        author: const ForumAuthor(id: 'user-1', name: 'Carlos', handle: 'carlos'),
        content: 'Comentário com correções efetuadas.',
        visibility: 'PUBLIC',
        status: 'ACTIVE',
        depth: 1,
        isEdited: true,
        editedAt: DateTime(2026, 11, 4),
        likesCount: 0,
        isLikedByMe: false,
        createdAt: DateTime(2026, 11, 4),
        updatedAt: DateTime(2026, 11, 4),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ForumTopicTile(
                  topic: editedTopic,
                  onTap: () {},
                  onLikeTap: () {},
                ),
                ForumCommentThread(
                  comment: editedComment,
                  currentUserId: 'user-1',
                  collapsedCommentIds: const {},
                  onToggleCollapse: (_) {},
                  onReplyTap: (_) {},
                  onLikeTap: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify (editado) indicators are rendered
      expect(find.text('(editado)'), findsNWidgets(2));
    });

    testWidgets('renders sanitized removed placeholder without author PII when comment is DELETED',
        (WidgetTester tester) async {
      final deletedComment = ForumComment(
        id: 'com-del-1',
        topicId: 'top-mod-1',
        authorId: 'user-1',
        author: null, // Sanitized/redacted
        content: '[Comentário removido pelo autor]',
        visibility: 'PUBLIC',
        status: 'DELETED',
        depth: 1,
        isEdited: false,
        likesCount: 0,
        isLikedByMe: false,
        createdAt: DateTime(2026, 11, 4),
        updatedAt: DateTime(2026, 11, 4),
        replies: [
          ForumComment(
            id: 'com-child-1',
            topicId: 'top-mod-1',
            authorId: 'user-2',
            author: const ForumAuthor(id: 'user-2', name: 'Beatriz', handle: 'bia'),
            content: 'Resposta filha preservada intacta',
            visibility: 'PUBLIC',
            status: 'ACTIVE',
            depth: 2,
            isEdited: false,
            likesCount: 1,
            isLikedByMe: false,
            createdAt: DateTime(2026, 11, 4),
            updatedAt: DateTime(2026, 11, 4),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForumCommentThread(
              comment: deletedComment,
              currentUserId: 'user-2',
              collapsedCommentIds: const {},
              onToggleCollapse: (_) {},
              onReplyTap: (_) {},
              onLikeTap: (_) {},
            ),
          ),
        ),
      );

      // Verify sanitized text
      expect(find.text('[Comentário removido pelo autor]'), findsOneWidget);
      // Verify child reply is visible
      expect(find.text('Resposta filha preservada intacta'), findsOneWidget);
      // Verify Beatriz is displayed but author of deleted comment is anonymous
      expect(find.text('Beatriz (@bia)'), findsOneWidget);
      expect(find.text('Removido'), findsOneWidget); // sanitized name for deleted comment
    });
  });
}
