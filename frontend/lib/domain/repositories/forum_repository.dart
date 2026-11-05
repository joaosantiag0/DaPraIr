import '../entities/forum_category.dart';
import '../entities/forum_topic.dart';
import '../entities/forum_comment.dart';

abstract class ForumRepository {
  Future<List<ForumCategory>> getCategories({bool? isActive});

  Future<List<ForumTopic>> getTopics({
    String? categoryId,
    String? sortBy,
    String? query,
    int? limit,
    int? offset,
  });

  Future<ForumTopic> getTopicById(String topicId);

  Future<ForumTopic> createTopic({
    required String categoryId,
    required String title,
    required String content,
    String visibility = 'PUBLIC',
  });

  Future<ForumTopic> updateTopic(
    String topicId, {
    String? title,
    String? content,
    String? visibility,
  });

  Future<void> deleteTopic(String topicId);

  Future<bool> toggleTopicLike(String topicId);

  Future<List<ForumComment>> getComments(
    String topicId, {
    int? limit,
    int? offset,
  });

  Future<ForumComment> createComment(
    String topicId, {
    String? parentId,
    required String content,
    String visibility = 'PUBLIC',
  });

  Future<ForumComment> updateComment(
    String commentId, {
    required String content,
    String? visibility,
  });

  Future<void> deleteComment(String commentId);

  Future<bool> toggleCommentLike(String commentId);

  Future<void> reportContent({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  });
}
