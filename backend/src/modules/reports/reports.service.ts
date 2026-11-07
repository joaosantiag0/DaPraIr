import { prisma } from '../../core/database/prisma.js';
import { BadRequestError, NotFoundError } from '../../core/errors/app-error.js';
import { adminService } from '../admin/admin.service.js';

export interface CreateReportDTO {
  reporterId: string;
  targetType: 'REVIEW' | 'MESSAGE' | 'USER' | 'EVENT' | 'MEDIA' | 'FORUM_TOPIC' | 'FORUM_COMMENT';
  targetId: string;
  reason: 'INACCURATE_DATA' | 'INAPPROPRIATE_MEDIA' | 'HARASSMENT' | 'SPAM' | 'OTHER';
  details?: string;
}

export class ReportsService {
  /**
   * File content report and apply automatic quarantine threshold (FR-023, FR-024)
   * - 1 to 2 distinct reports: status -> UNDER_REVIEW
   * - >= 3 distinct reports: status -> QUARANTINED (auto-hidden from public queries)
   */
  async createReport(data: CreateReportDTO) {
    const { reporterId, targetType, targetId, reason, details } = data;

    // Check if reporter already reported this target
    const existing = await prisma.contentReport.findFirst({
      where: {
        reporter_id: reporterId,
        target_type: targetType,
        target_id: targetId,
      },
    });

    if (existing) {
      throw new BadRequestError('Você já enviou uma denúncia para este conteúdo');
    }

    // Verify target exists
    await this.verifyTargetExists(targetType, targetId);

    // Create report record
    const report = await prisma.contentReport.create({
      data: {
        reporter_id: reporterId,
        target_type: targetType,
        target_id: targetId,
        reason,
        details,
        status: 'PENDING',
      },
    });

    // Count distinct reporters for this target
    const distinctReportsCount = await prisma.contentReport.count({
      where: {
        target_type: targetType,
        target_id: targetId,
      },
    });

    // Determine quarantine status
    let newStatus: string | null = null;
    if (distinctReportsCount >= 3) {
      newStatus = 'QUARANTINED';
    } else if (distinctReportsCount >= 1) {
      newStatus = 'UNDER_REVIEW';
    }

    if (newStatus) {
      await this.updateTargetStatus(targetType, targetId, newStatus, distinctReportsCount);
    }

    return {
      reportId: report.id,
      targetType: report.target_type,
      targetId: report.target_id,
      distinctReportsCount,
      targetStatus: newStatus,
    };
  }

  /**
   * List reports for moderation queue
   */
  async listReports(params: { status?: string; limit?: number; offset?: number }) {
    const { status, limit = 20, offset = 0 } = params;

    const where = status ? { status } : {};

    const [reports, total] = await Promise.all([
      prisma.contentReport.findMany({
        where,
        include: {
          reporter: { select: { id: true, name: true, handle: true } },
          resolver: { select: { id: true, name: true, handle: true } },
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset,
      }),
      prisma.contentReport.count({ where }),
    ]);

    return {
      reports: await Promise.all(
        reports.map(async (r) => ({
          id: r.id,
          reporter: r.reporter,
          targetType: r.target_type,
          targetId: r.target_id,
          reason: r.reason,
          details: r.details,
          status: r.status,
          createdAt: r.created_at,
          resolver: r.resolver,
          resolvedAt: r.resolved_at,
          resolutionNotes: r.resolution_notes,
          targetContent: await adminService.fetchTargetContent(r.target_type, r.target_id),
        }))
      ),
      total,
    };
  }

  /**
   * Moderation action by human reviewer
   */
  async resolveReport(params: {
    reportId: string;
    resolverId: string;
    action: 'RESOLVE_REMOVE' | 'RESOLVE_RESTORE' | 'DISMISS';
    resolutionNotes?: string;
  }) {
    const { reportId, resolverId, action, resolutionNotes } = params;

    const report = await prisma.contentReport.findUnique({
      where: { id: reportId },
    });

    if (!report) {
      throw new NotFoundError('Denúncia não encontrada');
    }

    const reportStatus = action === 'DISMISS' ? 'DISMISSED' : 'RESOLVED';

    await prisma.contentReport.update({
      where: { id: reportId },
      data: {
        status: reportStatus,
        resolved_by: resolverId,
        resolved_at: new Date(),
        resolution_notes: resolutionNotes,
      },
    });

    // Update target status based on resolution
    if (action === 'RESOLVE_REMOVE') {
      await this.updateTargetStatus(report.target_type, report.target_id, 'REMOVED', 0);
    } else if (action === 'RESOLVE_RESTORE' || action === 'DISMISS') {
      await this.updateTargetStatus(report.target_type, report.target_id, 'PUBLISHED', 0);
    }

    return {
      reportId,
      status: reportStatus,
      action,
    };
  }

  private async verifyTargetExists(targetType: string, targetId: string) {
    switch (targetType) {
      case 'REVIEW': {
        const review = await prisma.placeReview.findUnique({ where: { id: targetId } });
        if (!review) throw new NotFoundError('Avaliação não encontrada');
        break;
      }
      case 'MEDIA': {
        const media = await prisma.placeMedia.findUnique({ where: { id: targetId } });
        if (!media) throw new NotFoundError('Mídia não encontrada');
        break;
      }
      case 'EVENT': {
        const event = await prisma.event.findUnique({ where: { id: targetId } });
        if (!event) throw new NotFoundError('Evento não encontrado');
        break;
      }
      case 'USER': {
        const user = await prisma.user.findUnique({ where: { id: targetId } });
        if (!user) throw new NotFoundError('Usuário não encontrado');
        break;
      }
      case 'FORUM_TOPIC': {
        const topic = await prisma.forumTopic.findUnique({ where: { id: targetId } });
        if (!topic) throw new NotFoundError('Tópico não encontrado');
        break;
      }
      case 'FORUM_COMMENT': {
        const comment = await prisma.forumComment.findUnique({ where: { id: targetId } });
        if (!comment) throw new NotFoundError('Comentário não encontrado');
        break;
      }
    }
  }

  private async updateTargetStatus(targetType: string, targetId: string, status: string, reportCount: number) {
    if (targetType === 'REVIEW') {
      const review = await prisma.placeReview.update({
        where: { id: targetId },
        data: {
          status,
          report_count: reportCount,
        },
      });

      // Recalculate place overall score when review status changes
      const activeReviews = await prisma.placeReview.findMany({
        where: {
          place_id: review.place_id,
          status: { in: ['PUBLISHED', 'UNDER_REVIEW'] },
        },
        select: { average_score: true },
      });

      const totalReviews = activeReviews.length;
      const sumScores = activeReviews.reduce((sum, r) => sum + Number(r.average_score), 0);
      const newScore = totalReviews > 0 ? Number((sumScores / totalReviews).toFixed(2)) : 0;

      await prisma.place.update({
        where: { id: review.place_id },
        data: {
          overall_score: newScore,
          total_reviews: totalReviews,
        },
      });
    } else if (targetType === 'MEDIA') {
      const mediaStatus = status === 'PUBLISHED' ? 'ACTIVE' : status;
      await prisma.placeMedia.update({
        where: { id: targetId },
        data: {
          status: mediaStatus,
          report_count: reportCount,
        },
      });
    } else if (targetType === 'FORUM_TOPIC') {
      const topicStatus = status === 'QUARANTINED' ? 'REMOVED_BY_ADMIN' : (status === 'PUBLISHED' ? 'ACTIVE' : status);
      await prisma.forumTopic.update({
        where: { id: targetId },
        data: { status: topicStatus },
      });
    } else if (targetType === 'FORUM_COMMENT') {
      const commentStatus = status === 'QUARANTINED' ? 'REMOVED_BY_ADMIN' : (status === 'PUBLISHED' ? 'ACTIVE' : status);
      await prisma.forumComment.update({
        where: { id: targetId },
        data: { status: commentStatus },
      });
    }
  }
}

export const reportsService = new ReportsService();
