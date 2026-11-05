import 'package:equatable/equatable.dart';
import '../../../domain/entities/forum_category.dart';
import '../../../domain/entities/forum_topic.dart';
import '../../../domain/entities/forum_comment.dart';

abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {
  const ForumInitial();
}

class ForumHomeLoading extends ForumState {
  const ForumHomeLoading();
}

class ForumHomeLoaded extends ForumState {
  final List<ForumCategory> categories;
  final List<ForumTopic> highlightedTopics;

  const ForumHomeLoaded({
    required this.categories,
    required this.highlightedTopics,
  });

  @override
  List<Object?> get props => [categories, highlightedTopics];
}

class CategoryTopicsLoading extends ForumState {
  const CategoryTopicsLoading();
}

class CategoryTopicsLoaded extends ForumState {
  final String categoryId;
  final List<ForumTopic> topics;
  final String sortBy;
  final String? query;

  const CategoryTopicsLoaded({
    required this.categoryId,
    required this.topics,
    this.sortBy = 'recent',
    this.query,
  });

  CategoryTopicsLoaded copyWith({
    List<ForumTopic>? topics,
    String? sortBy,
    String? query,
  }) {
    return CategoryTopicsLoaded(
      categoryId: categoryId,
      topics: topics ?? this.topics,
      sortBy: sortBy ?? this.sortBy,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [categoryId, topics, sortBy, query];
}

class TopicDetailLoading extends ForumState {
  const TopicDetailLoading();
}

class TopicDetailLoaded extends ForumState {
  final ForumTopic topic;
  final List<ForumComment> comments;
  final Set<String> collapsedCommentIds;

  const TopicDetailLoaded({
    required this.topic,
    required this.comments,
    this.collapsedCommentIds = const {},
  });

  TopicDetailLoaded copyWith({
    ForumTopic? topic,
    List<ForumComment>? comments,
    Set<String>? collapsedCommentIds,
  }) {
    return TopicDetailLoaded(
      topic: topic ?? this.topic,
      comments: comments ?? this.comments,
      collapsedCommentIds: collapsedCommentIds ?? this.collapsedCommentIds,
    );
  }

  @override
  List<Object?> get props => [topic, comments, collapsedCommentIds];
}

class TopicCreating extends ForumState {
  const TopicCreating();
}

class TopicCreated extends ForumState {
  final ForumTopic topic;

  const TopicCreated({required this.topic});

  @override
  List<Object?> get props => [topic];
}

class ForumOperationSuccess extends ForumState {
  final String message;

  const ForumOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForumError extends ForumState {
  final String message;

  const ForumError({required this.message});

  @override
  List<Object?> get props => [message];
}
