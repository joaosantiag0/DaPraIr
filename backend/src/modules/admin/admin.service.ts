import { prisma } from '../../core/database/prisma.js';
import { BadRequestError, NotFoundError } from '../../core/errors/app-error.js';
import { auditService } from './audit.service.js';

export class AdminService {
  /**
   * Estatísticas gerais do painel de controle
   */
  async getDashboardStats() {
    const [pendingReportsCount, actionsTodayCount, activePenaltiesCount, totalUsersCount] =
      await Promise.all([
        prisma.contentReport.count({ where: { status: 'PENDING' } }),
        prisma.moderationAction.count({
          where: {
            created_at: {
              gte: new Date(new Date().setHours(0, 0, 0, 0)),
            },
          },
        }),
        prisma.userPenalty.count({ where: { status: 'ACTIVE' } }),
        prisma.user.count(),
      ]);

    return {
      pendingReportsCount,
      actionsTodayCount,
      activePenaltiesCount,
      totalUsersCount,
    };
  }

  // ==========================================
  // USER STORY 1: Fila de Denúncias
  // ==========================================

  async listReports(filters: {
    status?: string;
    targetType?: string;
    limit?: number;
    offset?: number;
  }) {
    const { status, targetType, limit = 20, offset = 0 } = filters;
    const where: any = {};
    if (status) where.status = status;
    if (targetType) where.target_type = targetType;

    const [items, total] = await Promise.all([
      prisma.contentReport.findMany({
        where,
        include: {
          reporter: {
            select: { id: true, name: true, handle: true },
          },
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset,
      }),
      prisma.contentReport.count({ where }),
    ]);

    return {
      total,
      limit,
      offset,
      items: items.map((r) => ({
        id: r.id,
        targetType: r.target_type,
        targetId: r.target_id,
        reason: r.reason,
        details: r.details,
        status: r.status,
        reporterMaskedName: r.reporter ? `${r.reporter.name.slice(0, 2)}***` : 'Anônimo',
        createdAt: r.created_at.toISOString(),
      })),
    };
  }

  async getReportDetails(id: string) {
    const report = await prisma.contentReport.findUnique({
      where: { id },
      include: {
        reporter: {
          select: { id: true, name: true, handle: true },
        },
      },
    });

    if (!report) {
      throw new NotFoundError('Denúncia não encontrada');
    }

    // Fetch contextual target content
    let targetContent: any = null;
    if (report.target_type === 'FORUM_TOPIC') {
      targetContent = await prisma.forumTopic.findUnique({
        where: { id: report.target_id },
        include: { author: { select: { id: true, name: true, handle: true } } },
      });
    } else if (report.target_type === 'FORUM_COMMENT') {
      targetContent = await prisma.forumComment.findUnique({
        where: { id: report.target_id },
        include: { author: { select: { id: true, name: true, handle: true } } },
      });
    } else if (report.target_type === 'PLACE_REVIEW') {
      targetContent = await prisma.placeReview.findUnique({
        where: { id: report.target_id },
        include: { user: { select: { id: true, name: true, handle: true } } },
      });
    } else if (report.target_type === 'USER') {
      targetContent = await prisma.user.findUnique({
        where: { id: report.target_id },
        select: { id: true, name: true, handle: true, role: true, status: true },
      });
    }

    const priorReportsCount = await prisma.contentReport.count({
      where: {
        target_type: report.target_type,
        target_id: report.target_id,
      },
    });

    return {
      id: report.id,
      targetType: report.target_type,
      targetId: report.target_id,
      reason: report.reason,
      details: report.details,
      status: report.status,
      reporterMaskedName: report.reporter ? `${report.reporter.name.slice(0, 2)}***` : 'Anônimo',
      createdAt: report.created_at.toISOString(),
      targetContent,
      priorReportsCount,
    };
  }

  async resolveReport(params: {
    reportId: string;
    moderatorId: string;
    action: 'ACCEPT_ACTION_APPLIED' | 'DISMISS_UNFOUNDED';
    resolutionNotes: string;
  }) {
    const { reportId, moderatorId, action, resolutionNotes } = params;

    const report = await prisma.contentReport.findUnique({
      where: { id: reportId },
    });

    if (!report) {
      throw new NotFoundError('Denúncia não encontrada');
    }

    const newStatus =
      action === 'ACCEPT_ACTION_APPLIED' ? 'RESOLVED_SANCTIONED' : 'DISMISSED';

    const updated = await prisma.contentReport.update({
      where: { id: reportId },
      data: {
        status: newStatus,
        resolved_by: moderatorId,
        resolution_notes: resolutionNotes,
        resolved_at: new Date(),
      },
    });

    // Log resolution in audit trail
    await auditService.logAction({
      moderatorId,
      actionType: action === 'ACCEPT_ACTION_APPLIED' ? 'RESOLVE_REPORT' : 'DISMISS_REPORT',
      targetType: 'REPORT',
      targetId: reportId,
      reason: resolutionNotes,
      metadata: {
        targetType: report.target_type,
        targetId: report.target_id,
        resolutionAction: action,
      },
    });

    return updated;
  }

  // ==========================================
  // USER STORY 2: Gestão e Moderação de Conteúdos
  // ==========================================

  async listUnifiedContent(filters: {
    type?: string;
    status?: string;
    query?: string;
    authorId?: string;
    limit?: number;
    offset?: number;
  }) {
    const { type = 'ALL', status, query, authorId, limit = 20, offset = 0 } = filters;

    const items: any[] = [];

    // Query Forum Topics
    if (type === 'ALL' || type === 'FORUM_TOPIC') {
      const topicWhere: any = {};
      if (status === 'ACTIVE') topicWhere.status = 'ACTIVE';
      else if (status === 'HIDDEN') topicWhere.status = 'HIDDEN_BY_ADMIN';
      else if (status === 'REMOVED') topicWhere.status = 'REMOVED_BY_ADMIN';
      if (authorId) topicWhere.author_id = authorId;
      if (query) {
        topicWhere.OR = [
          { title: { contains: query, mode: 'insensitive' } },
          { content: { contains: query, mode: 'insensitive' } },
        ];
      }

      const topics = await prisma.forumTopic.findMany({
        where: topicWhere,
        include: { author: { select: { id: true, name: true, handle: true } } },
        orderBy: { created_at: 'desc' },
        take: limit,
      });

      for (const t of topics) {
        items.push({
          id: t.id,
          type: 'FORUM_TOPIC',
          titleOrSnippet: t.title,
          content: t.content,
          author: t.author,
          status: t.status,
          createdAt: t.created_at.toISOString(),
        });
      }
    }

    // Query Forum Comments
    if (type === 'ALL' || type === 'FORUM_COMMENT') {
      const commentWhere: any = {};
      if (status === 'ACTIVE') commentWhere.status = 'ACTIVE';
      else if (status === 'HIDDEN') commentWhere.status = 'HIDDEN_BY_ADMIN';
      else if (status === 'REMOVED') commentWhere.status = 'REMOVED_BY_ADMIN';
      if (authorId) commentWhere.author_id = authorId;
      if (query) {
        commentWhere.content = { contains: query, mode: 'insensitive' };
      }

      const comments = await prisma.forumComment.findMany({
        where: commentWhere,
        include: { author: { select: { id: true, name: true, handle: true } } },
        orderBy: { created_at: 'desc' },
        take: limit,
      });

      for (const c of comments) {
        items.push({
          id: c.id,
          type: 'FORUM_COMMENT',
          titleOrSnippet: c.content.slice(0, 100),
          content: c.content,
          author: c.author,
          status: c.status,
          createdAt: c.created_at.toISOString(),
        });
      }
    }

    // Query Place Reviews
    if (type === 'ALL' || type === 'PLACE_REVIEW') {
      const reviewWhere: any = {};
      if (status === 'ACTIVE') reviewWhere.status = 'ACTIVE';
      else if (status === 'HIDDEN') reviewWhere.status = 'HIDDEN';
      else if (status === 'REMOVED') reviewWhere.status = 'REMOVED';
      if (authorId) reviewWhere.user_id = authorId;
      if (query) {
        reviewWhere.general_comment = { contains: query, mode: 'insensitive' };
      }

      const reviews = await prisma.placeReview.findMany({
        where: reviewWhere,
        include: { user: { select: { id: true, name: true, handle: true } } },
        orderBy: { created_at: 'desc' },
        take: limit,
      });

      for (const r of reviews) {
        items.push({
          id: r.id,
          type: 'PLACE_REVIEW',
          titleOrSnippet: r.general_comment || 'Avaliação sem texto',
          content: r.general_comment || '',
          author: r.user,
          status: r.status,
          createdAt: r.created_at.toISOString(),
        });
      }
    }

    // Sort combined items by createdAt desc and slice for pagination
    items.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    const paginatedItems = items.slice(offset, offset + limit);

    return {
      total: items.length,
      limit,
      offset,
      items: paginatedItems,
    };
  }

  async hideContent(params: {
    moderatorId: string;
    type: 'FORUM_TOPIC' | 'FORUM_COMMENT' | 'PLACE_REVIEW' | 'PLACE_MEDIA';
    id: string;
    reason: string;
  }) {
    const { moderatorId, type, id, reason } = params;
    let cascadeCount = 0;

    await prisma.$transaction(async (tx) => {
      if (type === 'FORUM_TOPIC') {
        const topic = await tx.forumTopic.findUnique({ where: { id } });
        if (!topic) throw new NotFoundError('Tópico não encontrado');

        await tx.forumTopic.update({
          where: { id },
          data: { status: 'HIDDEN_BY_ADMIN' },
        });

        // Cascade to all comments of this topic
        const updatedComments = await tx.forumComment.updateMany({
          where: { topic_id: id },
          data: { status: 'HIDDEN_BY_ADMIN' },
        });
        cascadeCount = updatedComments.count;
      } else if (type === 'FORUM_COMMENT') {
        const comment = await tx.forumComment.findUnique({ where: { id } });
        if (!comment) throw new NotFoundError('Comentário não encontrado');

        await tx.forumComment.update({
          where: { id },
          data: { status: 'HIDDEN_BY_ADMIN' },
        });
      } else if (type === 'PLACE_REVIEW') {
        const review = await tx.placeReview.findUnique({ where: { id } });
        if (!review) throw new NotFoundError('Avaliação não encontrada');

        await tx.placeReview.update({
          where: { id },
          data: { status: 'HIDDEN' },
        });
      } else if (type === 'PLACE_MEDIA') {
        const media = await tx.placeMedia.findUnique({ where: { id } });
        if (!media) throw new NotFoundError('Mídia não encontrada');

        await tx.placeMedia.update({
          where: { id },
          data: { status: 'HIDDEN' },
        });
      }

      await tx.moderationAction.create({
        data: {
          moderator_id: moderatorId,
          action_type: 'HIDE_CONTENT',
          target_type: type,
          target_id: id,
          reason,
          metadata: { cascadeCount },
        },
      });
    });

    return {
      targetId: id,
      newStatus: 'HIDDEN',
      cascadeCount,
      actionLogged: true,
    };
  }

  async restoreContent(params: {
    moderatorId: string;
    type: 'FORUM_TOPIC' | 'FORUM_COMMENT' | 'PLACE_REVIEW' | 'PLACE_MEDIA';
    id: string;
    reason: string;
  }) {
    const { moderatorId, type, id, reason } = params;
    let cascadeCount = 0;

    await prisma.$transaction(async (tx) => {
      if (type === 'FORUM_TOPIC') {
        const topic = await tx.forumTopic.findUnique({ where: { id } });
        if (!topic) throw new NotFoundError('Tópico não encontrado');

        await tx.forumTopic.update({
          where: { id },
          data: { status: 'ACTIVE' },
        });

        const updatedComments = await tx.forumComment.updateMany({
          where: { topic_id: id, status: 'HIDDEN_BY_ADMIN' },
          data: { status: 'ACTIVE' },
        });
        cascadeCount = updatedComments.count;
      } else if (type === 'FORUM_COMMENT') {
        await tx.forumComment.update({
          where: { id },
          data: { status: 'ACTIVE' },
        });
      } else if (type === 'PLACE_REVIEW') {
        await tx.placeReview.update({
          where: { id },
          data: { status: 'ACTIVE' },
        });
      } else if (type === 'PLACE_MEDIA') {
        await tx.placeMedia.update({
          where: { id },
          data: { status: 'APPROVED' },
        });
      }

      await tx.moderationAction.create({
        data: {
          moderator_id: moderatorId,
          action_type: 'RESTORE_CONTENT',
          target_type: type,
          target_id: id,
          reason,
          metadata: { cascadeCount },
        },
      });
    });

    return {
      targetId: id,
      newStatus: 'ACTIVE',
      cascadeCount,
      actionLogged: true,
    };
  }

  async deleteContent(params: {
    moderatorId: string;
    type: 'FORUM_TOPIC' | 'FORUM_COMMENT' | 'PLACE_REVIEW' | 'PLACE_MEDIA';
    id: string;
    reason: string;
  }) {
    const { moderatorId, type, id, reason } = params;
    let cascadeCount = 0;

    await prisma.$transaction(async (tx) => {
      if (type === 'FORUM_TOPIC') {
        const topic = await tx.forumTopic.findUnique({ where: { id } });
        if (!topic) throw new NotFoundError('Tópico não encontrado');

        await tx.forumTopic.update({
          where: { id },
          data: { status: 'REMOVED_BY_ADMIN' },
        });

        // Cascade delete on all subthreads/comments
        const updatedComments = await tx.forumComment.updateMany({
          where: { topic_id: id },
          data: { status: 'REMOVED_BY_ADMIN' },
        });
        cascadeCount = updatedComments.count;
      } else if (type === 'FORUM_COMMENT') {
        await tx.forumComment.update({
          where: { id },
          data: { status: 'REMOVED_BY_ADMIN' },
        });
      } else if (type === 'PLACE_REVIEW') {
        await tx.placeReview.update({
          where: { id },
          data: { status: 'REMOVED' },
        });
      } else if (type === 'PLACE_MEDIA') {
        await tx.placeMedia.update({
          where: { id },
          data: { status: 'REJECTED' },
        });
      }

      await tx.moderationAction.create({
        data: {
          moderator_id: moderatorId,
          action_type: 'DELETE_CONTENT',
          target_type: type,
          target_id: id,
          reason,
          metadata: { cascadeCount },
        },
      });
    });

    return {
      targetId: id,
      newStatus: 'REMOVED',
      cascadeCount,
      actionLogged: true,
    };
  }

  // ==========================================
  // USER STORY 3: Gestão de Usuários e Sanções
  // ==========================================

  async listUsers(filters: { status?: string; query?: string; limit?: number; offset?: number }) {
    const { status, query, limit = 20, offset = 0 } = filters;
    const where: any = {};
    if (status) where.status = status;
    if (query) {
      where.OR = [
        { name: { contains: query, mode: 'insensitive' } },
        { handle: { contains: query, mode: 'insensitive' } },
        { email: { contains: query, mode: 'insensitive' } },
      ];
    }

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true,
          name: true,
          handle: true,
          email: true,
          role: true,
          status: true,
          created_at: true,
          _count: {
            select: { penalties_received: true },
          },
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset,
      }),
      prisma.user.count({ where }),
    ]);

    return {
      total,
      limit,
      offset,
      items: users.map((u) => ({
        id: u.id,
        name: u.name,
        handle: u.handle,
        email: u.email,
        role: u.role,
        status: u.status,
        penaltiesCount: u._count.penalties_received,
        createdAt: u.created_at.toISOString(),
      })),
    };
  }

  async getUserDetails(id: string) {
    const user = await prisma.user.findUnique({
      where: { id },
      include: {
        penalties_received: {
          orderBy: { created_at: 'desc' },
          include: {
            moderator: { select: { id: true, name: true, handle: true } },
          },
        },
        _count: {
          select: {
            forum_topics: true,
            forum_comments: true,
            reviews: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundError('Usuário não encontrado');
    }

    return {
      id: user.id,
      name: user.name,
      handle: user.handle,
      email: user.email,
      role: user.role,
      status: user.status,
      sessionInvalidatedAt: user.session_invalidated_at?.toISOString() || null,
      stats: {
        topicsCount: user._count.forum_topics,
        commentsCount: user._count.forum_comments,
        reviewsCount: user._count.reviews,
      },
      penalties: user.penalties_received.map((p) => ({
        id: p.id,
        userId: p.user_id,
        penaltyType: p.penalty_type,
        reason: p.reason,
        startsAt: p.starts_at.toISOString(),
        endsAt: p.ends_at?.toISOString() || null,
        status: p.status,
        moderatorName: p.moderator.name,
      })),
      createdAt: user.created_at.toISOString(),
    };
  }

  async applyUserPenalty(params: {
    moderatorId: string;
    userId: string;
    penaltyType: 'WARNING' | 'SUSPENSION_7_DAYS' | 'PERMANENT_BAN';
    reason: string;
  }) {
    const { moderatorId, userId, penaltyType, reason } = params;

    const targetUser = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!targetUser) {
      throw new NotFoundError('Usuário não encontrado');
    }

    if (targetUser.role === 'ADMIN') {
      throw new BadRequestError('Não é permitido penalizar outro administrador');
    }

    const now = new Date();
    let endsAt: Date | null = null;
    let newStatus = targetUser.status;
    let shouldInvalidateSessions = false;

    if (penaltyType === 'WARNING') {
      newStatus = 'WARNED';
    } else if (penaltyType === 'SUSPENSION_7_DAYS') {
      newStatus = 'SUSPENDED';
      endsAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
      shouldInvalidateSessions = true;
    } else if (penaltyType === 'PERMANENT_BAN') {
      newStatus = 'BANNED';
      shouldInvalidateSessions = true;
    }

    const result = await prisma.$transaction(async (tx) => {
      // Create penalty record
      const penalty = await tx.userPenalty.create({
        data: {
          user_id: userId,
          moderator_id: moderatorId,
          penalty_type: penaltyType,
          reason,
          starts_at: now,
          ends_at: endsAt,
          status: 'ACTIVE',
        },
      });

      // Update user status and session_invalidated_at
      await tx.user.update({
        where: { id: userId },
        data: {
          status: newStatus,
          ...(shouldInvalidateSessions ? { session_invalidated_at: now } : {}),
        },
      });

      // Audit log
      const actionType =
        penaltyType === 'WARNING'
          ? 'WARN_USER'
          : penaltyType === 'SUSPENSION_7_DAYS'
            ? 'SUSPEND_USER'
            : 'BAN_USER';

      await tx.moderationAction.create({
        data: {
          moderator_id: moderatorId,
          action_type: actionType,
          target_type: 'USER',
          target_id: userId,
          reason,
          metadata: {
            penaltyId: penalty.id,
            penaltyType,
            endsAt: endsAt?.toISOString() || null,
          },
        },
      });

      return penalty;
    });

    return {
      id: result.id,
      userId: result.user_id,
      penaltyType: result.penalty_type,
      reason: result.reason,
      startsAt: result.starts_at.toISOString(),
      endsAt: result.ends_at?.toISOString() || null,
      status: result.status,
    };
  }

  async revokePenalty(params: {
    moderatorId: string;
    userId: string;
    penaltyId: string;
    reason: string;
  }) {
    const { moderatorId, userId, penaltyId, reason } = params;

    const penalty = await prisma.userPenalty.findFirst({
      where: { id: penaltyId, user_id: userId },
    });

    if (!penalty) {
      throw new NotFoundError('Penalidade não encontrada');
    }

    await prisma.$transaction(async (tx) => {
      await tx.userPenalty.update({
        where: { id: penaltyId },
        data: {
          status: 'REVOKED',
          revoked_by: moderatorId,
          revocation_reason: reason,
        },
      });

      // Check if user has other active penalties
      const otherActive = await tx.userPenalty.findFirst({
        where: {
          user_id: userId,
          status: 'ACTIVE',
          id: { not: penaltyId },
        },
      });

      if (!otherActive) {
        await tx.user.update({
          where: { id: userId },
          data: { status: 'ACTIVE' },
        });
      }

      await tx.moderationAction.create({
        data: {
          moderator_id: moderatorId,
          action_type: 'UNBAN_USER',
          target_type: 'USER',
          target_id: userId,
          reason,
          metadata: { revokedPenaltyId: penaltyId },
        },
      });
    });

    return this.getUserDetails(userId);
  }
}

export const adminService = new AdminService();
