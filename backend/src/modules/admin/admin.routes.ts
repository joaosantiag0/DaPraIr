import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { adminService } from './admin.service.js';
import { auditService } from './audit.service.js';
import { requireAdminOrModerator, requireAdmin } from './admin.middleware.js';
import {
  listReportsQuerySchema,
  resolveReportBodySchema,
  listContentQuerySchema,
  moderateContentBodySchema,
  deleteContentBodySchema,
  listUsersQuerySchema,
  applyPenaltyBodySchema,
  revokePenaltyBodySchema,
  listAuditLogsQuerySchema,
} from './admin.schemas.js';

export async function adminRoutes(app: FastifyInstance) {
  // Global hook for all /admin routes: must authenticate and satisfy RBAC
  const adminGuard = [app.authenticate, requireAdminOrModerator];
  const strictAdminGuard = [app.authenticate, requireAdmin];

  // ==========================================
  // DASHBOARD STATS
  // ==========================================
  app.get(
    '/admin/dashboard/stats',
    { preHandler: adminGuard },
    async (_request: FastifyRequest, reply: FastifyReply) => {
      const stats = await adminService.getDashboardStats();
      return reply.status(200).send(stats);
    }
  );

  // ==========================================
  // USER STORY 1: REPORTS QUEUE
  // ==========================================
  app.get(
    '/admin/reports',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const query = listReportsQuerySchema.parse(request.query);
      const result = await adminService.listReports(query);
      return reply.status(200).send(result);
    }
  );

  app.get(
    '/admin/reports/:id',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const report = await adminService.getReportDetails(id);
      return reply.status(200).send(report);
    }
  );

  app.patch(
    '/admin/reports/:id',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const body = resolveReportBodySchema.parse(request.body);
      const result = await adminService.resolveReport({
        reportId: id,
        moderatorId: request.user.id,
        action: body.action,
        resolutionNotes: body.resolutionNotes,
      });
      return reply.status(200).send(result);
    }
  );

  // ==========================================
  // USER STORY 2: CONTENT MODERATION
  // ==========================================
  app.get(
    '/admin/content',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const query = listContentQuerySchema.parse(request.query);
      const result = await adminService.listUnifiedContent(query);
      return reply.status(200).send(result);
    }
  );

  app.patch(
    '/admin/content/:type/:id/hide',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { type, id } = request.params as {
        type: 'FORUM_TOPIC' | 'FORUM_COMMENT' | 'PLACE_REVIEW' | 'PLACE_MEDIA';
        id: string;
      };
      const body = moderateContentBodySchema.parse(request.body);
      const result = await adminService.hideContent({
        moderatorId: request.user.id,
        type,
        id,
        reason: body.reason,
      });
      return reply.status(200).send(result);
    }
  );

  app.patch(
    '/admin/content/:type/:id/restore',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { type, id } = request.params as {
        type: 'FORUM_TOPIC' | 'FORUM_COMMENT' | 'PLACE_REVIEW' | 'PLACE_MEDIA';
        id: string;
      };
      const body = moderateContentBodySchema.parse(request.body);
      const result = await adminService.restoreContent({
        moderatorId: request.user.id,
        type,
        id,
        reason: body.reason,
      });
      return reply.status(200).send(result);
    }
  );

  app.delete(
    '/admin/content/:type/:id',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { type, id } = request.params as {
        type: 'FORUM_TOPIC' | 'FORUM_COMMENT' | 'PLACE_REVIEW' | 'PLACE_MEDIA';
        id: string;
      };
      const body = deleteContentBodySchema.parse(request.body);
      const result = await adminService.deleteContent({
        moderatorId: request.user.id,
        type,
        id,
        reason: body.reason,
      });
      return reply.status(200).send(result);
    }
  );

  // ==========================================
  // USER STORY 3: USER MANAGEMENT & PENALTIES
  // ==========================================
  app.get(
    '/admin/users',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const query = listUsersQuerySchema.parse(request.query);
      const result = await adminService.listUsers(query);
      return reply.status(200).send(result);
    }
  );

  app.get(
    '/admin/users/:id',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const user = await adminService.getUserDetails(id);
      return reply.status(200).send(user);
    }
  );

  app.post(
    '/admin/users/:id/penalties',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const body = applyPenaltyBodySchema.parse(request.body);
      const result = await adminService.applyUserPenalty({
        moderatorId: request.user.id,
        userId: id,
        penaltyType: body.penaltyType,
        reason: body.reason,
      });
      return reply.status(201).send(result);
    }
  );

  app.delete(
    '/admin/users/:id/penalties/:penaltyId',
    { preHandler: strictAdminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id, penaltyId } = request.params as { id: string; penaltyId: string };
      const body = revokePenaltyBodySchema.parse(request.body);
      const result = await adminService.revokePenalty({
        moderatorId: request.user.id,
        userId: id,
        penaltyId,
        reason: body.reason,
      });
      return reply.status(200).send(result);
    }
  );

  // ==========================================
  // USER STORY 4: AUDIT LOGS
  // ==========================================
  app.get(
    '/admin/audit-logs',
    { preHandler: adminGuard },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const query = listAuditLogsQuerySchema.parse(request.query);
      const result = await auditService.listLogs(query);
      return reply.status(200).send(result);
    }
  );
}
