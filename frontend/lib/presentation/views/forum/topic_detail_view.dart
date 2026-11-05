import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/forum/forum_bloc.dart';
import '../../bloc/forum/forum_event.dart';
import '../../bloc/forum/forum_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../components/forum_comment_thread.dart';
import '../../components/visibility_badge.dart';
import '../../components/guest_action_dialog.dart';
import '../../components/content_report_dialog.dart';
import '../../../domain/entities/forum_comment.dart';
import '../../../domain/entities/content_report.dart';

class TopicDetailView extends StatefulWidget {
  final String topicId;
  final bool isAuthenticated;
  final VoidCallback? onNavigateToLogin;

  const TopicDetailView({
    super.key,
    required this.topicId,
    this.isAuthenticated = false,
    this.onNavigateToLogin,
  });

  @override
  State<TopicDetailView> createState() => _TopicDetailViewState();
}

class _TopicDetailViewState extends State<TopicDetailView> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  ForumComment? _replyTarget;
  String _selectedVisibility = 'PUBLIC';

  @override
  void initState() {
    super.initState();
    context.read<ForumBloc>().add(LoadTopicDetailEvent(topicId: widget.topicId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _onRequireLogin(String actionTitle) {
    GuestActionDialog.show(
      context: context,
      actionTitle: actionTitle,
      onLoginPressed: () {
        Navigator.of(context).pop();
        if (widget.onNavigateToLogin != null) {
          widget.onNavigateToLogin!();
        }
      },
    );
  }

  void _onStartReply(ForumComment comment) {
    if (!widget.isAuthenticated) {
      _onRequireLogin('responder a comentários');
      return;
    }
    setState(() {
      _replyTarget = comment;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyTarget = null;
    });
  }

  void _submitComment(String topicVisibility) {
    if (!widget.isAuthenticated) {
      _onRequireLogin('participar do debate');
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // Enforce ceiling rule
    String effectiveVisibility = _selectedVisibility;
    if (topicVisibility == 'COMMUNITY' && effectiveVisibility == 'PUBLIC') {
      effectiveVisibility = 'COMMUNITY';
    } else if (topicVisibility == 'AUTHOR') {
      effectiveVisibility = 'AUTHOR';
    }

    context.read<ForumBloc>().add(
          SubmitCommentEvent(
            topicId: widget.topicId,
            parentId: _replyTarget?.id,
            content: text,
            visibility: effectiveVisibility,
          ),
        );

    _commentController.clear();
    setState(() {
      _replyTarget = null;
    });
    _commentFocusNode.unfocus();
  }

  void _showEditTopicDialog(String currentTitle, String currentContent, String currentVisibility) {
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);
    String visibility = currentVisibility;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar Debate'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Conteúdo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ForumBloc>().add(
                      EditTopicEvent(
                        topicId: widget.topicId,
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        visibility: visibility,
                      ),
                    );
                Navigator.of(ctx).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog({required bool isTopic, String? commentId}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTopic ? 'Excluir debate?' : 'Excluir comentário?'),
        content: Text(
          isTopic
              ? 'Se este debate contiver respostas da comunidade, o texto será substituído por aviso de remoção e os comentários serão preservados.'
              : 'Se este comentário possuir respostas aninhadas, as subthreads serão mantidas e seu conteúdo será removido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (isTopic) {
                context.read<ForumBloc>().add(DeleteTopicEvent(topicId: widget.topicId));
                Navigator.of(context).pop();
              } else if (commentId != null) {
                context.read<ForumBloc>().add(DeleteCommentEvent(commentId: commentId));
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(ForumComment comment) {
    final contentController = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Comentário'),
        content: TextField(
          controller: contentController,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Conteúdo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ForumBloc>().add(
                    EditCommentEvent(
                      commentId: comment.id,
                      content: contentController.text.trim(),
                    ),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog({required String targetType, required String targetId}) {
    ContentReportDialog.show(
      context: context,
      targetType: targetType,
      targetId: targetId,
      onSubmit: (reason, details) {
        context.read<ForumBloc>().add(
              ReportForumContentEvent(
                targetType: targetType,
                targetId: targetId,
                reason: reason.name.toUpperCase(),
                details: details,
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.id : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar debate',
            onPressed: () => context.read<ForumBloc>().add(LoadTopicDetailEvent(topicId: widget.topicId)),
          ),
        ],
      ),
      body: BlocConsumer<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is ForumOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF15803D)),
            );
          } else if (state is ForumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700),
            );
          }
        },
        builder: (context, state) {
          if (state is TopicDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TopicDetailLoaded) {
            final topic = state.topic;
            final isTopicAuthor = currentUserId != null && currentUserId == topic.authorId;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Topic Card Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges & Menu
                            Row(
                              children: [
                                if (topic.categoryName != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      topic.categoryName!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                VisibilityBadge(visibility: topic.visibility),
                                if (topic.isEdited) ...[
                                  const SizedBox(width: 6),
                                  const Text(
                                    '(editado)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showEditTopicDialog(topic.title, topic.content, topic.visibility);
                                    } else if (val == 'delete') {
                                      _showDeleteConfirmDialog(isTopic: true);
                                    } else if (val == 'report') {
                                      _showReportDialog(targetType: 'FORUM_TOPIC', targetId: topic.id);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    if (isTopicAuthor)
                                      const PopupMenuItem(value: 'edit', child: Text('Editar debate')),
                                    if (isTopicAuthor)
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Excluir debate', style: TextStyle(color: Colors.red)),
                                      ),
                                    if (!isTopicAuthor)
                                      const PopupMenuItem(value: 'report', child: Text('Denunciar debate')),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Topic Title
                            Text(
                              topic.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Topic Author Info
                            Text(
                              topic.author != null
                                  ? 'Publicado por ${topic.author!.name} (@${topic.author!.handle})'
                                  : 'Publicado por membro da comunidade',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const Divider(height: 24),

                            // Topic Body
                            Text(
                              topic.content,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Like Button & Counts
                            Row(
                              children: [
                                Semantics(
                                  button: true,
                                  label: topic.isLikedByMe
                                      ? 'Descurtir (${topic.likesCount})'
                                      : 'Curtir (${topic.likesCount})',
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (!widget.isAuthenticated) {
                                        _onRequireLogin('curtir debates');
                                      } else {
                                        context.read<ForumBloc>().add(ToggleTopicLikeEvent(topicId: topic.id));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: topic.isLikedByMe
                                          ? const Color(0xFF0D47A1)
                                          : const Color(0xFFEFF6FF),
                                      foregroundColor: topic.isLikedByMe ? Colors.white : const Color(0xFF0D47A1),
                                      elevation: 0,
                                    ),
                                    icon: Icon(
                                      topic.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                      size: 16,
                                    ),
                                    label: Text('${topic.likesCount} Curtidas'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${topic.commentsCount} comentários',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Comments Section Header
                      Row(
                        children: [
                          const Icon(Icons.forum_outlined, size: 20, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'Respostas e Subthreads (${state.comments.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Comments Tree
                      if (state.comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Nenhuma resposta ainda. Seja o primeiro a participar!',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                        )
                      else
                        ...state.comments.map(
                          (c) => ForumCommentThread(
                            comment: c,
                            collapsedCommentIds: state.collapsedCommentIds,
                            onToggleCollapse: (commentId) {
                              context.read<ForumBloc>().add(ToggleSubthreadCollapseEvent(commentId: commentId));
                            },
                            onReplyTap: (parentComment) => _onStartReply(parentComment),
                            onLikeTap: (commentToLike) {
                              if (!widget.isAuthenticated) {
                                _onRequireLogin('curtir comentários');
                              } else {
                                context.read<ForumBloc>().add(ToggleCommentLikeEvent(commentId: commentToLike.id));
                              }
                            },
                            onEditTap: (commentToEdit) => _showEditCommentDialog(commentToEdit),
                            onDeleteTap: (commentToDelete) =>
                                _showDeleteConfirmDialog(isTopic: false, commentId: commentToDelete.id),
                            onReportTap: (commentToReport) =>
                                _showReportDialog(targetType: 'FORUM_COMMENT', targetId: commentToReport.id),
                            currentUserId: currentUserId,
                          ),
                        ),
                    ],
                  ),
                ),

                // Reply Input Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Replying To Banner
                        if (_replyTarget != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Respondendo a @${_replyTarget!.author?.handle ?? "usuário"}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: _cancelReply,
                                  tooltip: 'Cancelar resposta direta',
                                ),
                              ],
                            ),
                          ),

                        // Input & Send Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: _replyTarget != null ? 'Escreva sua réplica...' : 'Adicione um comentário...',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Semantics(
                              button: true,
                              label: 'Enviar resposta',
                              child: IconButton.filled(
                                icon: const Icon(Icons.send),
                                onPressed: () => _submitComment(topic.visibility),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<ForumBloc>().add(LoadTopicDetailEvent(topicId: widget.topicId)),
              child: const Text('Carregar Detalhes'),
            ),
          );
        },
      ),
    );
  }
}
