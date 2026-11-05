import 'package:frontend/core/base/equatable.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class LoadForumHomeEvent extends ForumEvent {
  const LoadForumHomeEvent();
}

class LoadCategoryTopicsEvent extends ForumEvent {
  final String categoryId;
  final String sortBy;
  final String? query;

  const LoadCategoryTopicsEvent({
    required this.categoryId,
    this.sortBy = 'recent',
    this.query,
  });

  @override
  List<Object?> get props => [categoryId, sortBy, query];
}

class LoadTopicDetailEvent extends ForumEvent {
  final String topicId;

  const LoadTopicDetailEvent({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

class CreateTopicEvent extends ForumEvent {
  final String categoryId;
  final String title;
  final String content;
  final String visibility;

  const CreateTopicEvent({
    required this.categoryId,
    required this.title,
    required this.content,
    this.visibility = 'PUBLIC',
  });

  @override
  List<Object?> get props => [categoryId, title, content, visibility];
}

class ToggleTopicLikeEvent extends ForumEvent {
  final String topicId;

  const ToggleTopicLikeEvent({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

class SubmitCommentEvent extends ForumEvent {
  final String topicId;
  final String? parentId;
  final String content;
  final String visibility;

  const SubmitCommentEvent({
    required this.topicId,
    this.parentId,
    required this.content,
    this.visibility = 'PUBLIC',
  });

  @override
  List<Object?> get props => [topicId, parentId, content, visibility];
}

class ToggleCommentLikeEvent extends ForumEvent {
  final String commentId;

  const ToggleCommentLikeEvent({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class ToggleSubthreadCollapseEvent extends ForumEvent {
  final String commentId;

  const ToggleSubthreadCollapseEvent({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class EditTopicEvent extends ForumEvent {
  final String topicId;
  final String? title;
  final String? content;
  final String? visibility;

  const EditTopicEvent({
    required this.topicId,
    this.title,
    this.content,
    this.visibility,
  });

  @override
  List<Object?> get props => [topicId, title, content, visibility];
}

class DeleteTopicEvent extends ForumEvent {
  final String topicId;

  const DeleteTopicEvent({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

class EditCommentEvent extends ForumEvent {
  final String commentId;
  final String content;
  final String? visibility;

  const EditCommentEvent({
    required this.commentId,
    required this.content,
    this.visibility,
  });

  @override
  List<Object?> get props => [commentId, content, visibility];
}

class DeleteCommentEvent extends ForumEvent {
  final String commentId;

  const DeleteCommentEvent({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class ReportForumContentEvent extends ForumEvent {
  final String targetType;
  final String targetId;
  final String reason;
  final String? details;

  const ReportForumContentEvent({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details,
  });

  @override
  List<Object?> get props => [targetType, targetId, reason, details];
}
