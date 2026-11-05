import 'package:equatable/equatable.dart';
import 'forum_topic.dart';

class ForumComment extends Equatable {
  final String id;
  final String topicId;
  final String? parentId;
  final String authorId;
  final ForumAuthor? author;
  final String? replyToUserId;
  final String? replyToUserHandle;
  final String content;
  final int depth; // 1, 2, 3
  final String visibility; // PUBLIC, COMMUNITY, AUTHOR
  final String status; // ACTIVE, REMOVED_BY_AUTHOR, REMOVED_BY_ADMIN
  final bool isEdited;
  final DateTime? editedAt;
  final int likesCount;
  final bool isLikedByMe;
  final List<ForumComment> replies;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ForumComment({
    required this.id,
    required this.topicId,
    this.parentId,
    required this.authorId,
    this.author,
    this.replyToUserId,
    this.replyToUserHandle,
    required this.content,
    required this.depth,
    required this.visibility,
    required this.status,
    required this.isEdited,
    this.editedAt,
    required this.likesCount,
    this.isLikedByMe = false,
    this.replies = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] as String,
      topicId: json['topic_id'] as String,
      parentId: json['parent_id'] as String?,
      authorId: json['author_id'] as String,
      author: json['author'] != null ? ForumAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
      replyToUserId: json['reply_to_user_id'] as String?,
      replyToUserHandle: json['reply_to_user'] != null ? json['reply_to_user']['handle'] as String? : null,
      content: json['content'] as String,
      depth: (json['depth'] as num?)?.toInt() ?? 1,
      visibility: json['visibility'] as String? ?? 'PUBLIC',
      status: json['status'] as String? ?? 'ACTIVE',
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at'] as String) : null,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List<dynamic>)
              .map((e) => ForumComment.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ForumComment copyWith({
    String? content,
    String? visibility,
    String? status,
    bool? isEdited,
    DateTime? editedAt,
    int? likesCount,
    bool? isLikedByMe,
    List<ForumComment>? replies,
  }) {
    return ForumComment(
      id: id,
      topicId: topicId,
      parentId: parentId,
      authorId: authorId,
      author: author,
      replyToUserId: replyToUserId,
      replyToUserHandle: replyToUserHandle,
      content: content ?? this.content,
      depth: depth,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      replies: replies ?? this.replies,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        topicId,
        parentId,
        authorId,
        content,
        depth,
        visibility,
        status,
        isEdited,
        likesCount,
        isLikedByMe,
        replies,
        createdAt,
      ];
}
