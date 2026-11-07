import { describe, it, expect, vi, beforeEach } from 'vitest';
import { adminService } from '../../src/modules/admin/admin.service.js';
import { prisma } from '../../src/core/database/prisma.js';
import { auditService } from '../../src/modules/admin/audit.service.js';

vi.mock('../../src/core/database/prisma.js', () => ({
  prisma: {
    contentReport: {
      count: vi.fn(),
      findMany: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
    },
    moderationAction: {
      count: vi.fn(),
      create: vi.fn(),
      findMany: vi.fn(),
    },
    userPenalty: {
      count: vi.fn(),
      create: vi.fn(),
      findMany: vi.fn(),
      findFirst: vi.fn(),
      update: vi.fn(),
    },
    user: {
      count: vi.fn(),
      findMany: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
    },
    forumTopic: {
      findMany: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
    },
    forumComment: {
      findMany: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
      updateMany: vi.fn(),
    },
    placeReview: {
      findMany: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
    },
    placeMedia: {
      findUnique: vi.fn(),
      update: vi.fn(),
    },
    $transaction: vi.fn((callback) => callback(prisma)),
  },
}));

vi.mock('../../src/modules/admin/audit.service.js', () => ({
  auditService: {
    logAction: vi.fn().mockResolvedValue({ id: 'action-1' }),
    listLogs: vi.fn(),
  },
}));

describe('AdminService Unit Tests', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('getDashboardStats', () => {
    it('returns aggregated counts for dashboard', async () => {
      vi.mocked(prisma.contentReport.count).mockResolvedValue(5);
      vi.mocked(prisma.moderationAction.count).mockResolvedValue(12);
      vi.mocked(prisma.userPenalty.count).mockResolvedValue(3);
      vi.mocked(prisma.user.count).mockResolvedValue(150);

      const stats = await adminService.getDashboardStats();

      expect(stats).toEqual({
        pendingReportsCount: 5,
        actionsTodayCount: 12,
        activePenaltiesCount: 3,
        totalUsersCount: 150,
      });
    });
  });

  describe('User Story 1 - Fila de Denúncias', () => {
    it('lists reports with masked reporter name', async () => {
      vi.mocked(prisma.contentReport.findMany).mockResolvedValue([
        {
          id: 'rep-1',
          target_type: 'FORUM_TOPIC',
          target_id: 'top-1',
          reason: 'HARASSMENT',
          details: 'Discurso ofensivo',
          status: 'PENDING',
          created_at: new Date('2026-11-05T10:00:00Z'),
          reporter: { id: 'user-1', name: 'Maria Silva', handle: 'mariasilva' },
        } as any,
      ]);
      vi.mocked(prisma.contentReport.count).mockResolvedValue(1);

      const result = await adminService.listReports({ status: 'PENDING' });

      expect(result.total).toBe(1);
      expect(result.items[0].reporterMaskedName).toBe('Ma***');
      expect(result.items[0].targetType).toBe('FORUM_TOPIC');
    });

    it('resolves a report and logs audit action', async () => {
      vi.mocked(prisma.contentReport.findUnique).mockResolvedValue({
        id: 'rep-1',
        target_type: 'FORUM_TOPIC',
        target_id: 'top-1',
      } as any);
      vi.mocked(prisma.contentReport.update).mockResolvedValue({
        id: 'rep-1',
        status: 'RESOLVED_SANCTIONED',
      } as any);

      const res = await adminService.resolveReport({
        reportId: 'rep-1',
        moderatorId: 'mod-1',
        action: 'ACCEPT_ACTION_APPLIED',
        resolutionNotes: 'Conteúdo viola as diretrizes comunitárias.',
      });

      expect(res.status).toBe('RESOLVED_SANCTIONED');
      expect(auditService.logAction).toHaveBeenCalledWith(
        expect.objectContaining({
          moderatorId: 'mod-1',
          actionType: 'RESOLVE_REPORT',
          targetId: 'rep-1',
        })
      );
    });
  });

  describe('User Story 2 - Moderação de Conteúdos em Cascata', () => {
    it('hides a forum topic and cascades hiding to all related comments', async () => {
      vi.mocked(prisma.forumTopic.findUnique).mockResolvedValue({ id: 'top-1' } as any);
      vi.mocked(prisma.forumComment.updateMany).mockResolvedValue({ count: 4 });

      const res = await adminService.hideContent({
        moderatorId: 'mod-1',
        type: 'FORUM_TOPIC',
        id: 'top-1',
        reason: 'Desinformação grave sobre rampa acessível.',
      });

      expect(res.newStatus).toBe('HIDDEN');
      expect(res.cascadeCount).toBe(4);
      expect(prisma.forumTopic.update).toHaveBeenCalledWith({
        where: { id: 'top-1' },
        data: { status: 'HIDDEN_BY_ADMIN' },
      });
      expect(prisma.forumComment.updateMany).toHaveBeenCalledWith({
        where: { topic_id: 'top-1' },
        data: { status: 'HIDDEN_BY_ADMIN' },
      });
    });

    it('deletes a forum topic and cascades deletion to all related comments', async () => {
      vi.mocked(prisma.forumTopic.findUnique).mockResolvedValue({ id: 'top-1' } as any);
      vi.mocked(prisma.forumComment.updateMany).mockResolvedValue({ count: 8 });

      const res = await adminService.deleteContent({
        moderatorId: 'mod-1',
        type: 'FORUM_TOPIC',
        id: 'top-1',
        reason: 'Violação severa de direitos autorais e spam.',
      });

      expect(res.newStatus).toBe('REMOVED');
      expect(res.cascadeCount).toBe(8);
      expect(prisma.forumTopic.update).toHaveBeenCalledWith({
        where: { id: 'top-1' },
        data: { status: 'REMOVED_BY_ADMIN' },
      });
    });
  });

  describe('User Story 3 - Gestão de Usuários e Penalidades Progressivas', () => {
    it('applies WARNING penalty without invalidating session', async () => {
      vi.mocked(prisma.user.findUnique).mockResolvedValue({
        id: 'user-2',
        role: 'USER',
        status: 'ACTIVE',
      } as any);

      vi.mocked(prisma.userPenalty.create).mockResolvedValue({
        id: 'pen-1',
        user_id: 'user-2',
        penalty_type: 'WARNING',
        reason: 'Linguagem imprópria em comentário.',
        starts_at: new Date('2026-11-05T12:00:00Z'),
        ends_at: null,
        status: 'ACTIVE',
      } as any);

      const penalty = await adminService.applyUserPenalty({
        moderatorId: 'mod-1',
        userId: 'user-2',
        penaltyType: 'WARNING',
        reason: 'Linguagem imprópria em comentário.',
      });

      expect(penalty.penaltyType).toBe('WARNING');
      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: 'user-2' },
        data: { status: 'WARNED' },
      });
    });

    it('applies SUSPENSION_7_DAYS, sets ends_at and updates session_invalidated_at', async () => {
      vi.mocked(prisma.user.findUnique).mockResolvedValue({
        id: 'user-2',
        role: 'USER',
        status: 'WARNED',
      } as any);

      vi.mocked(prisma.userPenalty.create).mockImplementation(async ({ data }: any) => ({
        id: 'pen-2',
        user_id: data.user_id,
        penalty_type: data.penalty_type,
        reason: data.reason,
        starts_at: data.starts_at,
        ends_at: data.ends_at,
        status: data.status,
      }));

      const penalty = await adminService.applyUserPenalty({
        moderatorId: 'mod-1',
        userId: 'user-2',
        penaltyType: 'SUSPENSION_7_DAYS',
        reason: 'Reincidência de assédio em tópicos comunitários.',
      });

      expect(penalty.penaltyType).toBe('SUSPENSION_7_DAYS');
      expect(penalty.endsAt).toBeDefined();
      expect(prisma.user.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'user-2' },
          data: expect.objectContaining({
            status: 'SUSPENDED',
            session_invalidated_at: expect.any(Date),
          }),
        })
      );
    });

    it('rejects penalizing an admin user', async () => {
      vi.mocked(prisma.user.findUnique).mockResolvedValue({
        id: 'admin-2',
        role: 'ADMIN',
        status: 'ACTIVE',
      } as any);

      await expect(
        adminService.applyUserPenalty({
          moderatorId: 'mod-1',
          userId: 'admin-2',
          penaltyType: 'PERMANENT_BAN',
          reason: 'Tentativa indevida.',
        })
      ).rejects.toThrow('Não é permitido penalizar outro administrador');
    });
  });
});
