import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/forum_topic.dart';
import 'package:frontend/presentation/components/guest_action_dialog.dart';
import 'package:frontend/presentation/components/forum_topic_tile.dart';

void main() {
  final publicTopic = ForumTopic(
    id: 'pub-top-1',
    categoryId: 'cat-1',
    authorId: 'user-1',
    title: 'Debate Público sobre Rampas',
    content: 'Texto acessível a visitantes',
    visibility: 'PUBLIC',
    status: 'ACTIVE',
    isEdited: false,
    likesCount: 3,
    commentsCount: 2,
    isLikedByMe: false,
    createdAt: DateTime(2026, 11, 4),
    updatedAt: DateTime(2026, 11, 4),
  );

  group('Forum Guest Access & Interception Tests (US3)', () {
    testWidgets('unauthenticated user interaction triggers GuestActionDialog',
        (WidgetTester tester) async {
      bool loginTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ForumTopicTile(
                topic: publicTopic,
                onTap: () {},
                onLikeTap: () {
                  GuestActionDialog.show(
                    context: context,
                    actionTitle: 'curtir debates',
                    onLoginPressed: () {
                      loginTriggered = true;
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap on the Like button
      final likeButtonFinder = find.byIcon(Icons.thumb_up_alt_outlined);
      expect(likeButtonFinder, findsOneWidget);
      await tester.tap(likeButtonFinder);
      await tester.pumpAndSettle();

      // Check GuestActionDialog is visible
      expect(find.byType(GuestActionDialog), findsOneWidget);
      expect(find.text('Entrar no DáPraIr?'), findsOneWidget);

      // Tap the Fazer Login button inside dialog
      final loginButton = find.text('Fazer Login');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      expect(loginTriggered, true);
    });
  });
}
