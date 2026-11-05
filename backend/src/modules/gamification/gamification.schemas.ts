import { z } from 'zod';

export const leaderboardQuerySchema = z.object({
  period: z.enum(['weekly', 'monthly', 'all_time']).default('monthly'),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type LeaderboardQueryInput = z.infer<typeof leaderboardQuerySchema>;

export const transactionsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type TransactionsQueryInput = z.infer<typeof transactionsQuerySchema>;

export const updateGamificationPreferencesSchema = z.object({
  is_ranking_visible: z.boolean().optional(),
  use_anonymous_nickname: z.boolean().optional(),
  custom_nickname: z.string().trim().max(50).nullable().optional(),
});

export type UpdateGamificationPreferencesInput = z.infer<typeof updateGamificationPreferencesSchema>;

export const awardPointsInputSchema = z.object({
  userId: z.string().uuid(),
  actionType: z.enum([
    'AVALIACAO_LOCAL',
    'BONUS_FOTO',
    'BONUS_UTILIDADE',
    'TOPICO_FORUM',
    'RESPOSTA_UTIL',
    'ESTORNO',
  ]),
  points: z.number().int(),
  sourceId: z.string().uuid().optional(),
  sourceType: z.enum(['REVIEW', 'MEDIA', 'FORUM_TOPIC', 'FORUM_COMMENT']).optional(),
  description: z.string().max(255),
});

export type AwardPointsInput = z.infer<typeof awardPointsInputSchema>;
