import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/repositories/forum_repository.dart';
import 'package:frontend/domain/entities/forum_category.dart';
import 'package:frontend/domain/entities/forum_topic.dart';
import 'package:frontend/domain/entities/forum_comment.dart';
import 'package:frontend/presentation/bloc/forum/forum_bloc.dart';
import 'package:frontend/presentation/bloc/forum/forum_state.dart';
import 'package:frontend/presentation/views/forum/forum_home_view.dart';
import 'package:frontend/presentation/views/forum/category_topics_view.dart';

class MockForumRepository extends Mock implements ForumRepository {}

void main() {
  late MockForumRepository mockRepo;
  late ForumBloc forumBloc;

  final sampleCategories = [
    const ForumCategory(
      id: 'cat-1',
      name: 'Mobilidade Urbana',
      slug: 'mobilidade-urbana',
      description: 'Discussões sobre rotas e transporte',
      iconName: 'directions_bus',
      displayOrder: 1,
      isActive: true,
      topicsCount: 5,
    ),
  ];

  final sampleTopics = [
    ForumTopic(
      id: 'top-1',
      categoryId: 'cat-1',
      authorId: 'user-1',
      title: 'Calçadas com rampas rebaixadas',
      content: 'Avenida Paulista possui bom acesso.',
      visibility: 'PUBLIC',
      status: 'ACTIVE',
      isEdited: false,
      likesCount: 10,
      commentsCount: 2,
      isLikedByMe: false,
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    ),
  ];

  setUp(() {
    mockRepo = MockForumRepository();
    when(() => mockRepo.getCategories(isActive: any(named: 'isActive')))
        .thenAnswer((_) async => sampleCategories);
    when(() => mockRepo.getTopics(
          categoryId: any(named: 'categoryId'),
          sortBy: any(named: 'sortBy'),
          query: any(named: 'query'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => sampleTopics);
    when(() => mockRepo.getTopicById(any())).thenAnswer((_) async => sampleTopics.first);
    when(() => mockRepo.getComments(any())).thenAnswer((_) async => <ForumComment>[]);

    forumBloc = ForumBloc(forumRepository: mockRepo);
  });

  tearDown(() {
    forumBloc.close();
  });

  testWidgets('ForumHomeView maintains cached data and never shows Carregar Fórum button when returning from child screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: forumBloc,
          child: const ForumHomeView(),
        ),
      ),
    );

    // Initial load through ForumBloc
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    // Verify forum home loaded
    expect(find.text('Mobilidade Urbana'), findsOneWidget);
    expect(find.text('Calçadas com rampas rebaixadas'), findsOneWidget);
    expect(find.text('Carregar Fórum'), findsNothing);

    // Simulate child screen loading a specific topic, which changes ForumBloc state
    forumBloc.emit(TopicDetailLoaded(
      topic: sampleTopics.first,
      comments: const [],
    ));
    await tester.pump();

    // Verify that ForumHomeView retains cached categories & topics, and NEVER displays "Carregar Fórum"
    expect(find.text('Carregar Fórum'), findsNothing);
    expect(find.text('Mobilidade Urbana'), findsOneWidget);
    expect(find.text('Calçadas com rampas rebaixadas'), findsOneWidget);
  });

  testWidgets('ForumHomeView reloads smoothly when user logs in without showing Carregar Fórum', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: forumBloc,
          child: const ForumHomeView(isAuthenticated: false),
        ),
      ),
    );

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    expect(find.text('Mobilidade Urbana'), findsOneWidget);

    // Rebuild widget with isAuthenticated = true (simulating login)
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: forumBloc,
          child: const ForumHomeView(isAuthenticated: true),
        ),
      ),
    );

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    expect(find.text('Carregar Fórum'), findsNothing);
    expect(find.text('Mobilidade Urbana'), findsOneWidget);
  });

  testWidgets('CategoryTopicsView maintains cached topics and does not show Carregar Debates when returning', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: forumBloc,
          child: const CategoryTopicsView(
            categoryId: 'cat-1',
            categoryName: 'Mobilidade Urbana',
          ),
        ),
      ),
    );

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    expect(find.text('Calçadas com rampas rebaixadas'), findsOneWidget);
    expect(find.text('Carregar Debates'), findsNothing);

    // Simulate ForumBloc state transition (e.g. child TopicDetail opened)
    forumBloc.emit(TopicDetailLoaded(
      topic: sampleTopics.first,
      comments: const [],
    ));
    await tester.pump();

    // Still retains cached topics and does NOT show Carregar Debates button
    expect(find.text('Carregar Debates'), findsNothing);
    expect(find.text('Calçadas com rampas rebaixadas'), findsOneWidget);
  });
}
