import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/entities/forum_category.dart';
import 'package:frontend/domain/entities/forum_topic.dart';
import 'package:frontend/domain/repositories/forum_repository.dart';
import 'package:frontend/presentation/bloc/forum/forum_bloc.dart';
import 'package:frontend/presentation/bloc/forum/forum_event.dart';
import 'package:frontend/presentation/bloc/forum/forum_state.dart';

class MockForumRepository extends Mock implements ForumRepository {}

void main() {
  late MockForumRepository mockForumRepo;

  const testCategory = ForumCategory(
    id: 'cat-1',
    name: 'Mobilidade Urbana',
    slug: 'mobilidade-urbana',
    description: 'Debates sobre transporte',
    iconName: 'directions_bus',
    displayOrder: 1,
    isActive: true,
    topicsCount: 1,
  );

  final testTopic = ForumTopic(
    id: 'topic-1',
    categoryId: 'cat-1',
    authorId: 'user-1',
    title: 'Acessibilidade em metrôs',
    content: 'Discussão sobre elevadores no metrô.',
    visibility: 'PUBLIC',
    status: 'ACTIVE',
    isEdited: false,
    likesCount: 5,
    commentsCount: 2,
    isLikedByMe: false,
    createdAt: DateTime(2026, 11, 1),
    updatedAt: DateTime(2026, 11, 1),
  );

  setUp(() {
    mockForumRepo = MockForumRepository();
  });

  group('ForumBloc Tests (US1)', () {
    blocTest<ForumBloc, ForumState>(
      'emits [ForumHomeLoading, ForumHomeLoaded] when LoadForumHomeEvent succeeds',
      build: () {
        when(() => mockForumRepo.getCategories(isActive: true))
            .thenAnswer((_) async => [testCategory]);
        when(() => mockForumRepo.getTopics(limit: 5, sortBy: 'recent'))
            .thenAnswer((_) async => [testTopic]);
        return ForumBloc(forumRepository: mockForumRepo);
      },
      act: (bloc) => bloc.add(const LoadForumHomeEvent()),
      expect: () => [
        isA<ForumHomeLoading>(),
        isA<ForumHomeLoaded>()
            .having((s) => s.categories.length, 'categories.length', 1)
            .having((s) => s.highlightedTopics.length, 'highlightedTopics.length', 1),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [CategoryTopicsLoading, CategoryTopicsLoaded] on LoadCategoryTopicsEvent',
      build: () {
        when(() => mockForumRepo.getTopics(
              categoryId: 'cat-1',
              sortBy: 'recent',
              query: null,
            )).thenAnswer((_) async => [testTopic]);
        return ForumBloc(forumRepository: mockForumRepo);
      },
      act: (bloc) => bloc.add(const LoadCategoryTopicsEvent(categoryId: 'cat-1')),
      expect: () => [
        isA<CategoryTopicsLoading>(),
        isA<CategoryTopicsLoaded>()
            .having((s) => s.topics.first.title, 'title', 'Acessibilidade em metrôs'),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [TopicCreating, TopicCreated] on CreateTopicEvent',
      build: () {
        when(() => mockForumRepo.createTopic(
              categoryId: 'cat-1',
              title: 'Novo Tópico',
              content: 'Conteúdo detalhado do debate',
              visibility: 'PUBLIC',
            )).thenAnswer((_) async => testTopic);
        return ForumBloc(forumRepository: mockForumRepo);
      },
      act: (bloc) => bloc.add(const CreateTopicEvent(
        categoryId: 'cat-1',
        title: 'Novo Tópico',
        content: 'Conteúdo detalhado do debate',
        visibility: 'PUBLIC',
      )),
      expect: () => [
        isA<TopicCreating>(),
        isA<TopicCreated>().having((s) => s.topic.id, 'topic.id', 'topic-1'),
      ],
    );
  });
}
