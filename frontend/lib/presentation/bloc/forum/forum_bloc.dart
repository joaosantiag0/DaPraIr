import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/forum_repository.dart';
import '../../../domain/entities/forum_topic.dart';
import '../../../domain/entities/forum_comment.dart';
import 'forum_event.dart';
import 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository forumRepository;

  ForumBloc({required this.forumRepository}) : super(const ForumInitial()) {
    on<LoadForumHomeEvent>(_onLoadForumHome);
    on<LoadCategoryTopicsEvent>(_onLoadCategoryTopics);
    on<LoadTopicDetailEvent>(_onLoadTopicDetail);
    on<CreateTopicEvent>(_onCreateTopic);
    on<ToggleTopicLikeEvent>(_onToggleTopicLike);
    on<SubmitCommentEvent>(_onSubmitComment);
    on<ToggleCommentLikeEvent>(_onToggleCommentLike);
    on<ToggleSubthreadCollapseEvent>(_onToggleSubthreadCollapse);
    on<EditTopicEvent>(_onEditTopic);
    on<DeleteTopicEvent>(_onDeleteTopic);
    on<EditCommentEvent>(_onEditComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<ReportForumContentEvent>(_onReportForumContent);
  }

  Future<void> _onLoadForumHome(
    LoadForumHomeEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumHomeLoading());
    try {
      final categories = await forumRepository.getCategories(isActive: true);
      final topics = await forumRepository.getTopics(limit: 5, sortBy: 'recent');
      emit(ForumHomeLoaded(
        categories: categories,
        highlightedTopics: topics,
      ));
    } catch (e) {
      emit(ForumError(message: 'Erro ao carregar fórum: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCategoryTopics(
    LoadCategoryTopicsEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(const CategoryTopicsLoading());
    try {
      final topics = await forumRepository.getTopics(
        categoryId: event.categoryId,
        sortBy: event.sortBy,
        query: event.query,
      );
      emit(CategoryTopicsLoaded(
        categoryId: event.categoryId,
        topics: topics,
        sortBy: event.sortBy,
        query: event.query,
      ));
    } catch (e) {
      emit(ForumError(message: 'Erro ao carregar tópicos da categoria: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTopicDetail(
    LoadTopicDetailEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(const TopicDetailLoading());
    try {
      final topic = await forumRepository.getTopicById(event.topicId);
      final comments = await forumRepository.getComments(event.topicId);
      emit(TopicDetailLoaded(
        topic: topic,
        comments: comments,
      ));
    } catch (e) {
      emit(ForumError(message: 'Erro ao carregar detalhes do tópico: ${e.toString()}'));
    }
  }

  Future<void> _onCreateTopic(
    CreateTopicEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(const TopicCreating());
    try {
      final topic = await forumRepository.createTopic(
        categoryId: event.categoryId,
        title: event.title,
        content: event.content,
        visibility: event.visibility,
      );
      emit(TopicCreated(topic: topic));
    } catch (e) {
      emit(ForumError(message: 'Erro ao criar tópico: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTopicLike(
    ToggleTopicLikeEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final isLiked = await forumRepository.toggleTopicLike(event.topicId);

      // Optimistically update current state
      final current = state;
      if (current is CategoryTopicsLoaded) {
        final updatedTopics = current.topics.map((t) {
          if (t.id == event.topicId) {
            final newLikesCount = isLiked ? t.likesCount + 1 : (t.likesCount > 0 ? t.likesCount - 1 : 0);
            return t.copyWith(
              isLikedByMe: isLiked,
              likesCount: newLikesCount,
            );
          }
          return t;
        }).toList();
        emit(current.copyWith(topics: updatedTopics));
      } else if (current is TopicDetailLoaded && current.topic.id == event.topicId) {
        final newLikesCount = isLiked
            ? current.topic.likesCount + 1
            : (current.topic.likesCount > 0 ? current.topic.likesCount - 1 : 0);
        emit(current.copyWith(
          topic: current.topic.copyWith(
            isLikedByMe: isLiked,
            likesCount: newLikesCount,
          ),
        ));
      } else if (current is ForumHomeLoaded) {
        final updatedTopics = current.highlightedTopics.map((t) {
          if (t.id == event.topicId) {
            final newLikesCount = isLiked ? t.likesCount + 1 : (t.likesCount > 0 ? t.likesCount - 1 : 0);
            return t.copyWith(
              isLikedByMe: isLiked,
              likesCount: newLikesCount,
            );
          }
          return t;
        }).toList();
        emit(ForumHomeLoaded(
          categories: current.categories,
          highlightedTopics: updatedTopics,
        ));
      }
    } catch (e) {
      emit(ForumError(message: 'Erro ao registrar curtida: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitComment(
    SubmitCommentEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await forumRepository.createComment(
        event.topicId,
        parentId: event.parentId,
        content: event.content,
        visibility: event.visibility,
      );
      // Reload comments
      final comments = await forumRepository.getComments(event.topicId);
      final current = state;
      if (current is TopicDetailLoaded) {
        emit(current.copyWith(
          comments: comments,
          topic: current.topic.copyWith(
            commentsCount: current.topic.commentsCount + 1,
          ),
        ));
      }
    } catch (e) {
      emit(ForumError(message: 'Erro ao enviar comentário: ${e.toString()}'));
    }
  }

  Future<void> _onToggleCommentLike(
    ToggleCommentLikeEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final isLiked = await forumRepository.toggleCommentLike(event.commentId);
      final current = state;
      if (current is TopicDetailLoaded) {
        final updatedComments = _updateCommentLikeInTree(current.comments, event.commentId, isLiked);
        emit(current.copyWith(comments: updatedComments));
      }
    } catch (e) {
      emit(ForumError(message: 'Erro ao curtir comentário: ${e.toString()}'));
    }
  }

  List<ForumComment> _updateCommentLikeInTree(
    List<ForumComment> comments,
    String commentId,
    bool isLiked,
  ) {
    return comments.map((c) {
      if (c.id == commentId) {
        final newCount = isLiked ? c.likesCount + 1 : (c.likesCount > 0 ? c.likesCount - 1 : 0);
        return c.copyWith(
          isLikedByMe: isLiked,
          likesCount: newCount,
        );
      }
      if (c.replies.isNotEmpty) {
        return c.copyWith(
          replies: _updateCommentLikeInTree(c.replies, commentId, isLiked),
        );
      }
      return c;
    }).toList();
  }

  void _onToggleSubthreadCollapse(
    ToggleSubthreadCollapseEvent event,
    Emitter<ForumState> emit,
  ) {
    final current = state;
    if (current is TopicDetailLoaded) {
      final collapsed = Set<String>.from(current.collapsedCommentIds);
      if (collapsed.contains(event.commentId)) {
        collapsed.remove(event.commentId);
      } else {
        collapsed.add(event.commentId);
      }
      emit(current.copyWith(collapsedCommentIds: collapsed));
    }
  }

  Future<void> _onEditTopic(
    EditTopicEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final updated = await forumRepository.updateTopic(
        event.topicId,
        title: event.title,
        content: event.content,
        visibility: event.visibility,
      );
      final current = state;
      if (current is TopicDetailLoaded && current.topic.id == event.topicId) {
        emit(current.copyWith(topic: updated));
      }
      emit(const ForumOperationSuccess(message: 'Tópico atualizado com sucesso'));
    } catch (e) {
      emit(ForumError(message: 'Erro ao editar tópico: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTopic(
    DeleteTopicEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await forumRepository.deleteTopic(event.topicId);
      emit(const ForumOperationSuccess(message: 'Tópico removido'));
    } catch (e) {
      emit(ForumError(message: 'Erro ao remover tópico: ${e.toString()}'));
    }
  }

  Future<void> _onEditComment(
    EditCommentEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await forumRepository.updateComment(
        event.commentId,
        content: event.content,
        visibility: event.visibility,
      );
      final current = state;
      if (current is TopicDetailLoaded) {
        final comments = await forumRepository.getComments(current.topic.id);
        emit(current.copyWith(comments: comments));
      }
      emit(const ForumOperationSuccess(message: 'Comentário editado'));
    } catch (e) {
      emit(ForumError(message: 'Erro ao editar comentário: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await forumRepository.deleteComment(event.commentId);
      final current = state;
      if (current is TopicDetailLoaded) {
        final comments = await forumRepository.getComments(current.topic.id);
        emit(current.copyWith(comments: comments));
      }
      emit(const ForumOperationSuccess(message: 'Comentário removido'));
    } catch (e) {
      emit(ForumError(message: 'Erro ao remover comentário: ${e.toString()}'));
    }
  }

  Future<void> _onReportForumContent(
    ReportForumContentEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await forumRepository.reportContent(
        targetType: event.targetType,
        targetId: event.targetId,
        reason: event.reason,
        details: event.details,
      );
      emit(const ForumOperationSuccess(message: 'Denúncia enviada aos moderadores. Obrigado por proteger nossa comunidade!'));
    } catch (e) {
      emit(ForumError(message: 'Erro ao enviar denúncia: ${e.toString()}'));
    }
  }
}
