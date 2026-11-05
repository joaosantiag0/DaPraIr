import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/data/repositories/forum_repository_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ForumRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = ForumRepositoryImpl(dio: mockDio);
  });

  group('ForumRepositoryImpl Unit Tests', () {
    test('getCategories returns list of ForumCategory on 200 response', () async {
      when(() => mockDio.get(
            '/api/v1/forum/categories',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/forum/categories'),
          statusCode: 200,
          data: [
            {
              'id': 'cat-1',
              'name': 'Mobilidade Urbana',
              'slug': 'mobilidade-urbana',
              'description': 'Debates sobre transporte',
              'icon_name': 'directions_bus',
              'display_order': 1,
              'is_active': true,
              'topics_count': 5,
            }
          ],
        ),
      );

      final categories = await repository.getCategories();
      expect(categories.length, 1);
      expect(categories.first.name, 'Mobilidade Urbana');
      expect(categories.first.slug, 'mobilidade-urbana');
    });

    test('getTopics returns list of ForumTopic on 200 response', () async {
      when(() => mockDio.get(
            '/api/v1/forum/topics',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/forum/topics'),
          statusCode: 200,
          data: [
            {
              'id': 'top-1',
              'category_id': 'cat-1',
              'author_id': 'user-1',
              'title': 'Rampa de acesso',
              'content': 'Discussão sobre rampas',
              'visibility': 'PUBLIC',
              'status': 'ACTIVE',
              'is_edited': false,
              'likes_count': 3,
              'comments_count': 1,
              'is_liked_by_me': false,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
              'author': {
                'id': 'user-1',
                'name': 'Juliana',
                'handle': 'ju',
              },
            }
          ],
        ),
      );

      final topics = await repository.getTopics(categoryId: 'cat-1');
      expect(topics.length, 1);
      expect(topics.first.title, 'Rampa de acesso');
      expect(topics.first.visibility, 'PUBLIC');
    });

    test('createTopic sends POST and returns created ForumTopic', () async {
      when(() => mockDio.post(
            '/api/v1/forum/topics',
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/forum/topics'),
          statusCode: 201,
          data: {
            'id': 'top-new',
            'category_id': 'cat-1',
            'author_id': 'user-1',
            'title': 'Novo tópico de acessibilidade',
            'content': 'Corpo do novo debate...',
            'visibility': 'PUBLIC',
            'status': 'ACTIVE',
            'is_edited': false,
            'likes_count': 0,
            'comments_count': 0,
            'is_liked_by_me': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      final created = await repository.createTopic(
        categoryId: 'cat-1',
        title: 'Novo tópico de acessibilidade',
        content: 'Corpo do novo debate...',
        visibility: 'PUBLIC',
      );

      expect(created.id, 'top-new');
      expect(created.title, 'Novo tópico de acessibilidade');
    });

    test('toggleTopicLike sends POST and returns boolean state', () async {
      when(() => mockDio.post('/api/v1/forum/topics/top-1/like', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/forum/topics/top-1/like'),
          statusCode: 200,
          data: {'liked': true, 'likes_count': 4},
        ),
      );

      final liked = await repository.toggleTopicLike('top-1');
      expect(liked, true);
    });
  });
}
