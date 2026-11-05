import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/bloc/social/social_bloc.dart';
import 'package:frontend/presentation/bloc/chat/chat_bloc.dart';
import 'package:frontend/domain/entities/social_connection.dart';
import 'package:frontend/domain/entities/chat_message.dart';
import 'package:frontend/domain/repositories/social_repository.dart';
import 'package:frontend/domain/repositories/chat_repository.dart';

class MockSocialRepository extends Mock implements SocialRepository {}
class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockSocialRepository mockSocialRepo;
  late MockChatRepository mockChatRepo;
  late StreamController<ChatMessage> chatStreamController;

  final testConnection = SocialConnection(
    id: 'c-1',
    status: 'ACCEPTED',
    isOutgoing: false,
    createdAt: DateTime.now(),
    peer: const SocialPeer(id: 'p-1', name: 'Maria', handle: '@maria'),
  );

  final testMessage = ChatMessage(
    id: 'm-1',
    senderId: 'p-1',
    recipientId: 'my-id',
    content: 'Olá amigo!',
    status: 'READ',
    createdAt: DateTime.now(),
    isOutgoing: false,
  );

  setUp(() {
    mockSocialRepo = MockSocialRepository();
    mockChatRepo = MockChatRepository();
    chatStreamController = StreamController<ChatMessage>.broadcast();
    when(() => mockChatRepo.messageStream).thenAnswer((_) => chatStreamController.stream);
  });

  tearDown(() {
    chatStreamController.close();
  });

  group('SocialBloc', () {
    blocTest<SocialBloc, SocialState>(
      'emits [SocialLoading, SocialLoaded] on LoadSocialDataEvent',
      build: () {
        when(() => mockSocialRepo.getConnections()).thenAnswer((_) async => [testConnection]);
        when(() => mockSocialRepo.getRecommendations()).thenAnswer((_) async => []);
        when(() => mockSocialRepo.getBlockedUsers()).thenAnswer((_) async => []);
        return SocialBloc(repository: mockSocialRepo);
      },
      act: (bloc) => bloc.add(LoadSocialDataEvent()),
      expect: () => [
        SocialLoading(),
        SocialLoaded(
          friends: [testConnection],
          pendingReceived: const [],
          pendingSent: const [],
          blockedUsers: const [],
          recommendations: const [],
        ),
      ],
    );
  });

  group('ChatBloc', () {
    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatLoaded] on LoadChatMessagesEvent',
      build: () {
        when(() => mockChatRepo.getMessages('p-1')).thenAnswer((_) async => [testMessage]);
        return ChatBloc(repository: mockChatRepo);
      },
      act: (bloc) => bloc.add(const LoadChatMessagesEvent('p-1')),
      expect: () => [
        ChatLoading(),
        ChatLoaded(messages: [testMessage], peerUserId: 'p-1'),
      ],
    );
  });
}
