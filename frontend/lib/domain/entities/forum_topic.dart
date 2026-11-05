import 'package:frontend/core/base/equatable.dart';

class ForumAuthor extends Equatable {
  final String id;
  final String name;
  final String handle;
  final String? avatarUrl;

  const ForumAuthor({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
  });

  factory ForumAuthor.fromJson(Map<String, dynamic> json) {
    return ForumAuthor(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Usuário',
      handle: json['handle'] as String? ?? 'usuario',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'avatar_url': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, handle, avatarUrl];
}

class ForumTopic extends Equatable {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String authorId;
  final ForumAuthor? author;
  final String title;
  final String content;
  final String visibility; // PUBLIC, COMMUNITY, AUTHOR
  final String status; // ACTIVE, LOCKED, REMOVED_BY_AUTHOR, REMOVED_BY_ADMIN
  final bool isEdited;
  final DateTime? editedAt;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ForumTopic({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.authorId,
    this.author,
    required this.title,
    required this.content,
    required this.visibility,
    required this.status,
    required this.isEdited,
    this.editedAt,
    required this.likesCount,
    required this.commentsCount,
    this.isLikedByMe = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    return ForumTopic(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category'] != null ? json['category']['name'] as String? : null,
      authorId: json['author_id'] as String,
      author: json['author'] != null ? ForumAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
      title: json['title'] as String,
      content: json['content'] as String,
      visibility: json['visibility'] as String? ?? 'PUBLIC',
      status: json['status'] as String? ?? 'ACTIVE',
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at'] as String) : null,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ForumTopic copyWith({
    String? title,
    String? content,
    String? visibility,
    String? status,
    bool? isEdited,
    DateTime? editedAt,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
  }) {
    return ForumTopic(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      authorId: authorId,
      author: author,
      title: title ?? this.title,
      content: content ?? this.content,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        authorId,
        title,
        content,
        visibility,
        status,
        isEdited,
        likesCount,
        commentsCount,
        isLikedByMe,
        createdAt,
      ];
}
