import 'package:flutter/material.dart';
import '../../domain/entities/forum_comment.dart';
import 'visibility_badge.dart';
import 'subthread_collapse_toggle.dart';

class ForumCommentThread extends StatelessWidget {
  final ForumComment comment;
  final Set<String> collapsedCommentIds;
  final ValueChanged<String> onToggleCollapse;
  final ValueChanged<ForumComment> onReplyTap;
  final ValueChanged<ForumComment> onLikeTap;
  final ValueChanged<ForumComment>? onEditTap;
  final ValueChanged<ForumComment>? onDeleteTap;
  final ValueChanged<ForumComment>? onReportTap;
  final String? currentUserId;

  const ForumCommentThread({
    super.key,
    required this.comment,
    required this.collapsedCommentIds,
    required this.onToggleCollapse,
    required this.onReplyTap,
    required this.onLikeTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onReportTap,
    this.currentUserId,
  });

  double _getIndentation(int depth) {
    switch (depth) {
      case 2:
        return 16.0;
      case 3:
      default:
        return depth >= 3 ? 32.0 : 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = collapsedCommentIds.contains(comment.id);
    final hasReplies = comment.replies.isNotEmpty;
    final isAuthor = currentUserId != null && currentUserId == comment.authorId;
    final isRemoved = comment.status == 'DELETED' ||
        comment.status == 'REMOVED_BY_AUTHOR' ||
        comment.status == 'REMOVED_BY_ADMIN';

    final authorName = isRemoved
        ? 'Removido'
        : (comment.author != null ? comment.author!.name : 'Usuário comunitário');
    final authorHandle = isRemoved
        ? ''
        : (comment.author != null ? ' (@${comment.author!.handle})' : '');

    final semanticText =
        'Comentário nível ${comment.depth} de $authorName$authorHandle. '
        '${comment.replyToUserHandle != null ? "Em resposta a @${comment.replyToUserHandle}. " : ""}'
        'Conteúdo: ${comment.content}. ${comment.likesCount} curtidas.';

    return Padding(
      padding: EdgeInsets.only(
        left: _getIndentation(comment.depth),
        top: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single Comment Card
          Semantics(
            container: true,
            label: semanticText,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRemoved ? const Color(0xFFF8FAFC) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRemoved ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author & Visibility Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF0D47A1),
                        child: Text(
                          isRemoved ? '?' : (authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U'),
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            Text(
                              '$authorName$authorHandle',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isRemoved ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                              ),
                            ),
                            if (comment.replyToUserHandle != null && !isRemoved)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '@${comment.replyToUserHandle}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            if (comment.visibility != 'PUBLIC')
                              VisibilityBadge(visibility: comment.visibility, isCompact: true),
                            if (comment.isEdited && !isRemoved)
                              const Text(
                                '(editado)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Options Menu (Edit/Delete for author, Report for community)
                      if (!isRemoved)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748B)),
                          tooltip: 'Opções do comentário',
                          onSelected: (val) {
                            if (val == 'edit' && onEditTap != null) onEditTap!(comment);
                            if (val == 'delete' && onDeleteTap != null) onDeleteTap!(comment);
                            if (val == 'report' && onReportTap != null) onReportTap!(comment);
                          },
                          itemBuilder: (ctx) => [
                            if (isAuthor && onEditTap != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                            if (isAuthor && onDeleteTap != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Excluir', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            if (!isAuthor && onReportTap != null)
                              const PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(Icons.flag_outlined, size: 18, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Denunciar'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Content
                  Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: isRemoved ? FontStyle.italic : FontStyle.normal,
                      color: isRemoved ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Actions Row: Like & Reply buttons with min 48x48 dp touch target
                  if (!isRemoved)
                    Row(
                      children: [
                        // Like Button
                        Semantics(
                          button: true,
                          label: comment.isLikedByMe
                              ? 'Descurtir comentário (${comment.likesCount} curtidas)'
                              : 'Curtir comentário (${comment.likesCount} curtidas)',
                          child: InkWell(
                            onTap: () => onLikeTap(comment),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    comment.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                    size: 16,
                                    color: comment.isLikedByMe
                                        ? const Color(0xFF0D47A1)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${comment.likesCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: comment.isLikedByMe
                                          ? const Color(0xFF0D47A1)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reply Button
                        Semantics(
                          button: true,
                          label: 'Responder a este comentário de $authorName',
                          child: InkWell(
                            onTap: () => onReplyTap(comment),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.reply, size: 16, color: Color(0xFF0D47A1)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Responder',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D47A1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Collapse/Expand toggle button
          if (hasReplies)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: SubthreadCollapseToggle(
                isCollapsed: isCollapsed,
                repliesCount: comment.replies.length,
                onTap: () => onToggleCollapse(comment.id),
              ),
            ),

          // Nested Subthreads (rendered recursively if not collapsed)
          if (hasReplies && !isCollapsed)
            ...comment.replies.map(
              (reply) => ForumCommentThread(
                comment: reply,
                collapsedCommentIds: collapsedCommentIds,
                onToggleCollapse: onToggleCollapse,
                onReplyTap: onReplyTap,
                onLikeTap: onLikeTap,
                onEditTap: onEditTap,
                onDeleteTap: onDeleteTap,
                onReportTap: onReportTap,
                currentUserId: currentUserId,
              ),
            ),
        ],
      ),
    );
  }
}
