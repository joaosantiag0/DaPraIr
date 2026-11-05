import 'package:flutter/material.dart';
import '../../domain/entities/forum_topic.dart';
import 'visibility_badge.dart';

class ForumTopicTile extends StatelessWidget {
  final ForumTopic topic;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;

  const ForumTopicTile({
    super.key,
    required this.topic,
    required this.onTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    final authorDisplay = topic.author != null
        ? '${topic.author!.name} (@${topic.author!.handle})'
        : 'Usuário comunitário';

    final semanticText =
        'Tópico: ${topic.title}. Categoria: ${topic.categoryName ?? "Geral"}. '
        'Autor: $authorDisplay. '
        '${topic.likesCount} curtidas, ${topic.commentsCount} comentários. Toque para abrir debate.';

    return Semantics(
      container: true,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      label: semanticText,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header tags: Category & Visibility & Edited badge
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (topic.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          topic.categoryName!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    VisibilityBadge(visibility: topic.visibility, isCompact: true),
                    if (topic.isEdited)
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
                const SizedBox(height: 10),

                // Title
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // Excerpt
                Text(
                  topic.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),

                // Footer: Author & Counts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        authorDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Like Button with min 48x48 dp touch target
                        Semantics(
                          button: true,
                          label: topic.isLikedByMe
                              ? 'Descurtir tópico (${topic.likesCount} curtidas)'
                              : 'Curtir tópico (${topic.likesCount} curtidas)',
                          child: InkWell(
                            onTap: onLikeTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    topic.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                    size: 16,
                                    color: topic.isLikedByMe
                                        ? const Color(0xFF0D47A1)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${topic.likesCount}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: topic.isLikedByMe
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
                        // Comments Count
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              '${topic.commentsCount}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
