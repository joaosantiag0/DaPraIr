import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/views/social/chat_conversation_screen.dart';
import 'package:frontend/presentation/bloc/chat/chat_bloc.dart';
import 'package:frontend/domain/entities/chat_message.dart';

class MockChatBloc extends MockBloc<ChatEvent, ChatState> implements ChatBloc {}

void main() {
  late MockChatBloc mockChatBloc;

  final testMessages = [
    ChatMessage(
      id: 'msg-1',
      senderId: 'user-b',
      recipientId: 'user-a',
      content: 'Olá! Como está a acessibilidade na sua região?',
      status: 'READ',
      createdAt: DateTime.now(),
      isOutgoing: false,
    ),
    ChatMessage(
      id: 'msg-2',
      senderId: 'user-a',
      recipientId: 'user-b',
      content: 'Oi! Aqui tem várias rampas novas.',
      status: 'SENT',
      createdAt: DateTime.now(),
      isOutgoing: true,
    ),
  ];

  setUp(() {
    mockChatBloc = MockChatBloc();
    when(() => mockChatBloc.state).thenReturn(
      ChatLoaded(messages: testMessages, peerUserId: 'user-b'),
    );
  });

  testWidgets('ChatConversationScreen renders semantic messages and >= 48dp send action', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ChatBloc>.value(
          value: mockChatBloc,
          child: const ChatConversationScreen(
            peerUserId: 'user-b',
            peerName: 'Roberto Amigo',
            peerHandle: '@roberto',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Roberto Amigo'), findsOneWidget);
    expect(find.text('Olá! Como está a acessibilidade na sua região?'), findsOneWidget);
    expect(find.text('Oi! Aqui tem várias rampas novas.'), findsOneWidget);
    expect(find.text('Enviar'), findsOneWidget);

    // Verify Semantics
    expect(
      find.byWidgetPredicate((w) =>
          w is Semantics &&
          w.properties.label ==
              'Roberto Amigo disse: Olá! Como está a acessibilidade na sua região?'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) =>
          w is Semantics &&
          w.properties.label == 'Você disse: Oi! Aqui tem várias rampas novas.'),
      findsOneWidget,
    );

    semantics.dispose();
  });
}
