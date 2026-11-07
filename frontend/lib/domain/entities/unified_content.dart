import 'package:frontend/core/base/equatable.dart';

class UnifiedContent extends Equatable {
  final String id;
  final String type; // FORUM_TOPIC, FORUM_COMMENT, PLACE_REVIEW, PLACE_MEDIA
  final String titleOrSnippet;
  final String content;
  final String? authorName;
  final String? authorHandle;
  final String status;
  final DateTime createdAt;

  const UnifiedContent({
    required this.id,
    required this.type,
    required this.titleOrSnippet,
    required this.content,
    this.authorName,
    this.authorHandle,
    required this.status,
    required this.createdAt,
  });

  factory UnifiedContent.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return UnifiedContent(
      id: json['id'] as String,
      type: json['type'] as String,
      titleOrSnippet: json['titleOrSnippet'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorName: author?['name'] as String?,
      authorHandle: author?['handle'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        titleOrSnippet,
        content,
        authorName,
        authorHandle,
        status,
        createdAt,
      ];
}
