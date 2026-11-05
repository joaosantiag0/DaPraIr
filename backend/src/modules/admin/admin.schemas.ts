import { z } from 'zod';

export const listReportsQuerySchema = z.object({
  status: z.enum(['PENDING', 'IN_REVIEW', 'RESOLVED_SANCTIONED', 'DISMISSED']).optional(),
  targetType: z.enum(['FORUM_TOPIC', 'FORUM_COMMENT', 'PLACE_REVIEW', 'PLACE_MEDIA', 'USER', 'MESSAGE', 'EVENT']).optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export const resolveReportBodySchema = z.object({
  action: z.enum(['ACCEPT_ACTION_APPLIED', 'DISMISS_UNFOUNDED']),
  resolutionNotes: z.string().min(10, 'A justificativa de resolução deve ter no mínimo 10 caracteres'),
});

export const listContentQuerySchema = z.object({
  type: z.enum(['ALL', 'FORUM_TOPIC', 'FORUM_COMMENT', 'PLACE_REVIEW', 'PLACE_MEDIA']).default('ALL'),
  status: z.enum(['ACTIVE', 'HIDDEN', 'REMOVED']).optional(),
  query: z.string().optional(),
  authorId: z.string().uuid().optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export const moderateContentBodySchema = z.object({
  reason: z.string().min(10, 'A justificativa deve ter no mínimo 10 caracteres'),
});

export const deleteContentBodySchema = z.object({
  reason: z.string().min(10, 'A justificativa de exclusão deve ter no mínimo 10 caracteres'),
  confirm: z.literal(true, {
    errorMap: () => ({ message: 'Confirmação obrigatória para exclusão permanente' }),
  }),
});

export const listUsersQuerySchema = z.object({
  status: z.enum(['ACTIVE', 'WARNED', 'SUSPENDED', 'BANNED']).optional(),
  query: z.string().optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export const applyPenaltyBodySchema = z.object({
  penaltyType: z.enum(['WARNING', 'SUSPENSION_7_DAYS', 'PERMANENT_BAN']),
  reason: z.string().min(10, 'O motivo da penalidade deve ter no mínimo 10 caracteres'),
});

export const revokePenaltyBodySchema = z.object({
  reason: z.string().min(10, 'O motivo da revogação deve ter no mínimo 10 caracteres'),
});

export const listAuditLogsQuerySchema = z.object({
  moderatorId: z.string().uuid().optional(),
  actionType: z.string().optional(),
  targetType: z.string().optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});
