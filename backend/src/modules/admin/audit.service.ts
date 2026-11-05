import { prisma } from '../../core/database/prisma.js';

export interface LogActionParams {
  moderatorId: string;
  actionType:
    | 'HIDE_CONTENT'
    | 'RESTORE_CONTENT'
    | 'DELETE_CONTENT'
    | 'WARN_USER'
    | 'SUSPEND_USER'
    | 'BAN_USER'
    | 'UNBAN_USER'
    | 'DISMISS_REPORT'
    | 'RESOLVE_REPORT';
  targetType: 'FORUM_TOPIC' | 'FORUM_COMMENT' | 'PLACE_REVIEW' | 'PLACE_MEDIA' | 'USER' | 'REPORT';
  targetId: string;
  reason: string;
  metadata?: Record<string, any>;
}

export interface ListAuditLogsFilters {
  moderatorId?: string;
  actionType?: string;
  targetType?: string;
  limit?: number;
  offset?: number;
}

export class AuditService {
  /**
   * Grava uma ação de moderação imutável na trilha de auditoria (LGPD Art. 16)
   */
  async logAction(params: LogActionParams) {
    const { moderatorId, actionType, targetType, targetId, reason, metadata } = params;

    return prisma.moderationAction.create({
      data: {
        moderator_id: moderatorId,
        action_type: actionType,
        target_type: targetType,
        target_id: targetId,
        reason,
        metadata: metadata || {},
      },
    });
  }

  /**
   * Consulta paginada dos logs de auditoria com dados do moderador
   */
  async listLogs(filters: ListAuditLogsFilters) {
    const { moderatorId, actionType, targetType, limit = 20, offset = 0 } = filters;

    const where: any = {};
    if (moderatorId) where.moderator_id = moderatorId;
    if (actionType) where.action_type = actionType;
    if (targetType) where.target_type = targetType;

    const [items, total] = await Promise.all([
      prisma.moderationAction.findMany({
        where,
        include: {
          moderator: {
            select: {
              id: true,
              name: true,
              handle: true,
              role: true,
            },
          },
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset,
      }),
      prisma.moderationAction.count({ where }),
    ]);

    return {
      total,
      limit,
      offset,
      items: items.map((item) => ({
        id: item.id,
        moderatorId: item.moderator_id,
        moderatorName: item.moderator?.name || 'Administrador',
        moderatorHandle: item.moderator?.handle || 'admin',
        actionType: item.action_type,
        targetType: item.target_type,
        targetId: item.target_id,
        reason: item.reason,
        metadata: item.metadata,
        createdAt: item.created_at.toISOString(),
      })),
    };
  }
}

export const auditService = new AuditService();
