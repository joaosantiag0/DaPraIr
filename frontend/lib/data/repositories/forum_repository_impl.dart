import 'package:dio/dio.dart';
import '../../domain/entities/forum_category.dart';
import '../../domain/entities/forum_topic.dart';
import '../../domain/entities/forum_comment.dart';
import '../../domain/repositories/forum_repository.dart';

class ForumRepositoryImpl implements ForumRepository {
  final Dio dio;

  ForumRepositoryImpl({required this.dio});

  static const String _base = '/api/v1/forum';

  @override
  Future<List<ForumCategory>> getCategories({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive;
    }

    final response = await dio.get('$_base/categories', queryParameters: queryParams);
    final list = response.data as List<dynamic>;
    return list.map((json) => ForumCategory.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ForumTopic>> getTopics({
    String? categoryId,
    String? sortBy,
    String? query,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await dio.get('$_base/topics', queryParameters: queryParams);
    final list = response.data as List<dynamic>;
    return list.map((json) => ForumTopic.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ForumTopic> getTopicById(String topicId) async {
    final response = await dio.get('$_base/topics/$topicId');
    return ForumTopic.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ForumTopic> createTopic({
    required String categoryId,
    required String title,
    required String content,
    String visibility = 'PUBLIC',
  }) async {
    final response = await dio.post(
      '$_base/topics',
      data: {
        'category_id': categoryId,
        'title': title,
        'content': content,
        'visibility': visibility,
      },
    );
    return ForumTopic.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ForumTopic> updateTopic(
    String topicId, {
    String? title,
    String? content,
    String? visibility,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (visibility != null) data['visibility'] = visibility;

    final response = await dio.patch('$_base/topics/$topicId', data: data);
    return ForumTopic.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await dio.delete('$_base/topics/$topicId');
  }

  @override
  Future<bool> toggleTopicLike(String topicId) async {
    final response = await dio.post('$_base/topics/$topicId/like', data: {});
    final data = response.data as Map<String, dynamic>;
    return data['liked'] as bool? ?? false;
  }

  @override
  Future<List<ForumComment>> getComments(
    String topicId, {
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await dio.get('$_base/topics/$topicId/comments', queryParameters: queryParams);
    final list = response.data as List<dynamic>;
    return list.map((json) => ForumComment.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ForumComment> createComment(
    String topicId, {
    String? parentId,
    required String content,
    String visibility = 'PUBLIC',
  }) async {
    final response = await dio.post(
      '$_base/topics/$topicId/comments',
      data: {
        if (parentId != null) 'parent_id': parentId,
        'content': content,
        'visibility': visibility,
      },
    );
    return ForumComment.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ForumComment> updateComment(
    String commentId, {
    required String content,
    String? visibility,
  }) async {
    final data = <String, dynamic>{
      'content': content,
      if (visibility != null) 'visibility': visibility,
    };
    final response = await dio.patch('$_base/comments/$commentId', data: data);
    return ForumComment.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await dio.delete('$_base/comments/$commentId');
  }

  @override
  Future<bool> toggleCommentLike(String commentId) async {
    final response = await dio.post('$_base/comments/$commentId/like', data: {});
    final data = response.data as Map<String, dynamic>;
    return data['liked'] as bool? ?? false;
  }

  @override
  Future<void> reportContent({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    await dio.post(
      '$_base/reports',
      data: {
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        if (details != null && details.isNotEmpty) 'details': details,
      },
    );
  }
}
