import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { reportsService } from './reports.service.js';
import { z } from 'zod';

const createReportSchema = z.object({
  targetType: z.enum(['REVIEW', 'MESSAGE', 'USER', 'EVENT', 'MEDIA']),
  targetId: z.string().uuid(),
  reason: z.enum(['INACCURATE_DATA', 'INAPPROPRIATE_MEDIA', 'HARASSMENT', 'SPAM', 'OTHER']),
  details: z.string().max(1000).optional(),
});

const resolveReportSchema = z.object({
  action: z.enum(['RESOLVE_REMOVE', 'RESOLVE_RESTORE', 'DISMISS']),
  resolutionNotes: z.string().max(1000).optional(),
});

export async function reportsRoutes(app: FastifyInstance) {
  // File a report (FR-023, FR-024)
  app.post(
    '/reports',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = createReportSchema.parse(request.body);
      const result = await reportsService.createReport({
        reporterId: request.user.id,
        targetType: body.targetType,
        targetId: body.targetId,
        reason: body.reason,
        details: body.details,
      });
      return reply.status(201).send(result);
    }
  );

  // Moderation queue: list reports
  app.get(
    '/reports',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { status, limit = 20, offset = 0 } = request.query as any;
      const result = await reportsService.listReports({
        status,
        limit: Number(limit),
        offset: Number(offset),
      });
      return reply.status(200).send(result);
    }
  );

  // Moderation action
  app.patch(
    '/reports/:id',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const body = resolveReportSchema.parse(request.body);
      const result = await reportsService.resolveReport({
        reportId: id,
        resolverId: request.user.id,
        action: body.action,
        resolutionNotes: body.resolutionNotes,
      });
      return reply.status(200).send(result);
    }
  );
}
