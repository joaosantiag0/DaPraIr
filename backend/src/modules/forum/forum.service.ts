import { prisma } from '../../core/database/prisma.js';
import { Prisma } from '@prisma/client';

export class ForumService {
  async listCategories(filters?: { is_active?: boolean }) {
    const where: Prisma.ForumCategoryWhereInput = {};
    if (filters?.is_active !== undefined) {
      where.is_active = filters.is_active;
    }

    return prisma.forumCategory.findMany({
      where,
      orderBy: [{ display_order: 'asc' }, { name: 'asc' }],
    });
  }

  async getCategoryById(categoryId: string) {
    const category = await prisma.forumCategory.findUnique({
      where: { id: categoryId },
    });
    if (!category) {
      throw new Error('Category not found');
    }
    return category;
  }

  async listTopics(
    userId?: string,
    query?: {
      category_id?: string;
      sort_by?: 'recent' | 'likes' | 'comments';
      query?: string;
      visibility?: 'PUBLIC' | 'COMMUNITY' | 'AUTHOR';
      limit?: number;
      offset?: number;
    }
  ) {
    const where: Prisma.ForumTopicWhereInput = {
      status: { notIn: ['REMOVED_BY_ADMIN'] },
    };

    if (query?.category_id) {
      where.category_id = query.category_id;
    }

    // Visibility rules based on authentication context
    if (!userId) {
      // Anonymous Guest: strictly PUBLIC
      where.visibility = 'PUBLIC';
    } else {
      // Authenticated User: PUBLIC, COMMUNITY, or AUTHOR if created by self
      if (query?.visibility) {
        if (query.visibility === 'PUBLIC') {
          where.visibility = 'PUBLIC';
        } else if (query.visibility === 'COMMUNITY') {
          where.visibility = 'COMMUNITY';
        } else if (query.visibility === 'AUTHOR') {
          where.visibility = 'AUTHOR';
          where.author_id = userId;
        }
      } else {
        where.OR = [
          { visibility: { in: ['PUBLIC', 'COMMUNITY'] } },
          { visibility: 'AUTHOR', author_id: userId },
        ];
      }
    }

    if (query?.query) {
      where.AND = [
        {
          OR: [
            { title: { contains: query.query, mode: 'insensitive' } },
            { content: { contains: query.query, mode: 'insensitive' } },
          ],
        },
      ];
    }

    let orderBy: Prisma.ForumTopicOrderByWithRelationInput = { created_at: 'desc' };
    if (query?.sort_by === 'likes') {
      orderBy = { likes_count: 'desc' };
    } else if (query?.sort_by === 'comments') {
      orderBy = { comments_count: 'desc' };
    }

    const topics = await prisma.forumTopic.findMany({
      where,
      orderBy,
      take: query?.limit ?? 20,
      skip: query?.offset ?? 0,
      include: {
        category: {
          select: { id: true, name: true, slug: true, icon_name: true },
        },
        author: {
          select: { id: true, name: true, handle: true, avatar_url: true },
        },
        likes: userId
          ? {
              where: { user_id: userId },
              select: { user_id: true },
            }
          : false,
      },
    });

    return topics.map((t) => {
      const isLikedByMe = Boolean(t.likes && t.likes.length > 0);
      const { likes, ...topicData } = t;
      return {
        ...topicData,
        is_liked_by_me: isLikedByMe,
      };
    });
  }

  async getTopicById(topicId: string, userId?: string) {
    const topic = await prisma.forumTopic.findUnique({
      where: { id: topicId },
      include: {
        category: {
          select: { id: true, name: true, slug: true, icon_name: true },
        },
        author: {
          select: { id: true, name: true, handle: true, avatar_url: true },
        },
        likes: userId
          ? {
              where: { user_id: userId },
              select: { user_id: true },
            }
          : false,
      },
    });

    if (!topic || topic.status === 'REMOVED_BY_ADMIN') {
      throw new Error('Topic not found');
    }

    // Visibility access check
    if (topic.visibility === 'COMMUNITY' && !userId) {
      throw new Error('Forbidden: Community topic requires authentication');
    }
    if (topic.visibility === 'AUTHOR' && topic.author_id !== userId) {
      throw new Error('Forbidden: Author private topic');
    }

    const isLikedByMe = Boolean(topic.likes && topic.likes.length > 0);
    const { likes, ...topicData } = topic;

    return {
      ...topicData,
      is_liked_by_me: isLikedByMe,
    };
  }

  async createTopic(
    authorId: string,
    data: {
      category_id: string;
      title: string;
      content: string;
      visibility?: 'PUBLIC' | 'COMMUNITY' | 'AUTHOR';
    }
  ) {
    const category = await prisma.forumCategory.findUnique({
      where: { id: data.category_id },
    });

    if (!category || !category.is_active) {
      throw new Error('Category not found or inactive');
    }

    return prisma.$transaction(async (tx) => {
      const topic = await tx.forumTopic.create({
        data: {
          category_id: data.category_id,
          author_id: authorId,
          title: data.title,
          content: data.content,
          visibility: data.visibility ?? 'PUBLIC',
          status: 'ACTIVE',
        },
        include: {
          category: {
            select: { id: true, name: true, slug: true, icon_name: true },
          },
          author: {
            select: { id: true, name: true, handle: true, avatar_url: true },
          },
        },
      });

      await tx.forumCategory.update({
        where: { id: data.category_id },
        data: { topics_count: { increment: 1 } },
      });

      return {
        ...topic,
        is_liked_by_me: false,
      };
    });
  }

  async toggleTopicLike(userId: string, topicId: string) {
    return prisma.$transaction(async (tx) => {
      const topic = await tx.forumTopic.findUnique({
        where: { id: topicId },
      });

      if (!topic) {
        throw new Error('Topic not found');
      }

      const existingLike = await tx.forumTopicLike.findUnique({
        where: {
          user_id_topic_id: {
            user_id: userId,
            topic_id: topicId,
          },
        },
      });

      if (existingLike) {
        await tx.forumTopicLike.delete({
          where: { id: existingLike.id },
        });

        const updated = await tx.forumTopic.update({
          where: { id: topicId },
          data: { likes_count: { decrement: 1 } },
        });

        return { liked: false, likes_count: Math.max(0, updated.likes_count) };
      } else {
        await tx.forumTopicLike.create({
          data: {
            user_id: userId,
            topic_id: topicId,
          },
        });

        const updated = await tx.forumTopic.update({
          where: { id: topicId },
          data: { likes_count: { increment: 1 } },
        });

        return { liked: true, likes_count: updated.likes_count };
      }
    });
  }

  async createComment(
    authorId: string,
    topicId: string,
    data: {
      parent_id?: string | null;
      content: string;
      visibility?: 'PUBLIC' | 'COMMUNITY' | 'AUTHOR';
    }
  ) {
    const topic = await prisma.forumTopic.findUnique({
      where: { id: topicId },
    });

    if (!topic || topic.status === 'REMOVED_BY_ADMIN') {
      throw new Error('Topic not found or removed');
    }

    const commentVisibility = data.visibility ?? 'PUBLIC';

    // Ceiling Rule Validation
    if (topic.visibility === 'COMMUNITY' && commentVisibility === 'PUBLIC') {
      throw new Error('Regra do teto: Comentário em tópico da comunidade não pode ser público');
    }
    if (topic.visibility === 'AUTHOR' && commentVisibility !== 'AUTHOR') {
      throw new Error('Regra do teto: Comentário em tópico privado deve ter visibilidade privada');
    }

    let depth = 1;
    let replyToUserId: string | null = null;

    if (data.parent_id) {
      const parent = await prisma.forumComment.findUnique({
        where: { id: data.parent_id },
      });

      if (!parent || parent.topic_id !== topicId) {
        throw new Error('Parent comment not found in this topic');
      }

      replyToUserId = parent.author_id;
      if (parent.depth === 1) {
        depth = 2;
      } else {
        // Depth 2 or 3 -> stays at 3 with mention
        depth = 3;
      }
    }

    return prisma.$transaction(async (tx) => {
      const comment = await tx.forumComment.create({
        data: {
          topic_id: topicId,
          parent_id: data.parent_id ?? null,
          author_id: authorId,
          reply_to_user_id: replyToUserId,
          content: data.content,
          depth,
          visibility: commentVisibility,
          status: 'ACTIVE',
        },
        include: {
          author: {
            select: { id: true, name: true, handle: true, avatar_url: true },
          },
          reply_to_user: {
            select: { id: true, name: true, handle: true },
          },
        },
      });

      await tx.forumTopic.update({
        where: { id: topicId },
        data: { comments_count: { increment: 1 } },
      });

      return {
        ...comment,
        is_liked_by_me: false,
        replies: [],
      };
    });
  }

  async listCommentsTree(topicId: string, userId?: string) {
    const topic = await prisma.forumTopic.findUnique({
      where: { id: topicId },
    });

    if (!topic || topic.status === 'REMOVED_BY_ADMIN') {
      throw new Error('Topic not found');
    }

    const where: Prisma.ForumCommentWhereInput = {
      topic_id: topicId,
      status: { notIn: ['REMOVED_BY_ADMIN'] },
    };

    if (!userId) {
      where.visibility = 'PUBLIC';
    } else {
      where.OR = [
        { visibility: { in: ['PUBLIC', 'COMMUNITY'] } },
        { visibility: 'AUTHOR', author_id: userId },
        { visibility: 'AUTHOR', topic: { author_id: userId } },
      ];
    }

    const comments = await prisma.forumComment.findMany({
      where,
      orderBy: { created_at: 'asc' },
      include: {
        author: {
          select: { id: true, name: true, handle: true, avatar_url: true },
        },
        reply_to_user: {
          select: { id: true, name: true, handle: true },
        },
        likes: userId
          ? {
              where: { user_id: userId },
              select: { user_id: true },
            }
          : false,
      },
    });

    // Transform into hierarchical tree
    type CommentWithReplies = (typeof comments)[0] & {
      is_liked_by_me: boolean;
      replies: CommentWithReplies[];
    };

    const map = new Map<string, CommentWithReplies>();
    for (const c of comments) {
      const isLikedByMe = Boolean(c.likes && c.likes.length > 0);
      const { likes, ...commentData } = c;
      if (commentData.status === 'DELETED') {
        (commentData as any).author = null;
        (commentData as any).author_id = null;
      }
      map.set(c.id, {
        ...commentData,
        is_liked_by_me: isLikedByMe,
        replies: [],
      } as any);
    }

    const roots: CommentWithReplies[] = [];
    for (const c of comments) {
      const item = map.get(c.id)!;
      if (c.parent_id && map.has(c.parent_id)) {
        map.get(c.parent_id)!.replies.push(item);
      } else {
        roots.push(item);
      }
    }

    return roots;
  }

  async toggleCommentLike(userId: string, commentId: string) {
    return prisma.$transaction(async (tx) => {
      const comment = await tx.forumComment.findUnique({
        where: { id: commentId },
      });

      if (!comment) {
        throw new Error('Comment not found');
      }

      const existingLike = await tx.forumCommentLike.findUnique({
        where: {
          user_id_comment_id: {
            user_id: userId,
            comment_id: commentId,
          },
        },
      });

      if (existingLike) {
        await tx.forumCommentLike.delete({
          where: { id: existingLike.id },
        });

        const updated = await tx.forumComment.update({
          where: { id: commentId },
          data: { likes_count: { decrement: 1 } },
        });

        return { liked: false, likes_count: Math.max(0, updated.likes_count) };
      } else {
        await tx.forumCommentLike.create({
          data: {
            user_id: userId,
            comment_id: commentId,
          },
        });

        const updated = await tx.forumComment.update({
          where: { id: commentId },
          data: { likes_count: { increment: 1 } },
        });

        return { liked: true, likes_count: updated.likes_count };
      }
    });
  }

  async updateTopic(
    userId: string,
    topicId: string,
    data: { title?: string; content?: string }
  ) {
    const topic = await prisma.forumTopic.findUnique({
      where: { id: topicId },
    });

    if (!topic || topic.status === 'REMOVED_BY_ADMIN') {
      throw new Error('Topic not found');
    }

    if (topic.author_id !== userId) {
      throw new Error('Forbidden: Only the author can edit this topic');
    }

    return prisma.forumTopic.update({
      where: { id: topicId },
      data: {
        title: data.title ?? undefined,
        content: data.content ?? undefined,
        is_edited: true,
        edited_at: new Date(),
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            handle: true,
            avatar_url: true,
          },
        },
        category: {
          select: {
            id: true,
            name: true,
            slug: true,
          },
        },
      },
    });
  }

  async softDeleteTopic(userId: string, topicId: string) {
    const topic = await prisma.forumTopic.findUnique({
      where: { id: topicId },
    });

    if (!topic || topic.status === 'REMOVED_BY_ADMIN') {
      throw new Error('Topic not found');
    }

    if (topic.author_id !== userId) {
      throw new Error('Forbidden: Only the author can delete this topic');
    }

    return prisma.forumTopic.update({
      where: { id: topicId },
      data: {
        status: 'DELETED',
        content: '[Tópico removido pelo autor]',
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            handle: true,
          },
        },
      },
    });
  }

  async updateComment(
    userId: string,
    commentId: string,
    data: { content: string }
  ) {
    const comment = await prisma.forumComment.findUnique({
      where: { id: commentId },
    });

    if (!comment || comment.status === 'REMOVED_BY_ADMIN') {
      throw new Error('Comment not found');
    }

    if (comment.author_id !== userId) {
      throw new Error('Forbidden: Only the author can edit this comment');
    }

    return prisma.forumComment.update({
      where: { id: commentId },
      data: {
        content: data.content,
        is_edited: true,
        edited_at: new Date(),
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            handle: true,
          },
        },
      },
    });
  }

  async softDeleteComment(userId: string, commentId: string) {
    const comment = await prisma.forumComment.findUnique({
      where: { id: commentId },
    });

    if (!comment || comment.status === 'REMOVED_BY_ADMIN') {
      throw new Error('Comment not found');
    }

    if (comment.author_id !== userId) {
      throw new Error('Forbidden: Only the author can delete this comment');
    }

    return prisma.forumComment.update({
      where: { id: commentId },
      data: {
        status: 'DELETED',
        content: '[Comentário removido pelo autor]',
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            handle: true,
          },
        },
      },
    });
  }

  async reportContent(
    reporterId: string,
    data: {
      target_type: 'FORUM_TOPIC' | 'FORUM_COMMENT';
      target_id: string;
      reason: string;
      details?: string;
    }
  ) {
    return prisma.contentReport.create({
      data: {
        reporter_id: reporterId,
        target_type: data.target_type,
        target_id: data.target_id,
        reason: data.reason,
        details: data.details,
      },
    });
  }
}

export const forumService = new ForumService();
