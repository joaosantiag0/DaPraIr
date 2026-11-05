import { FastifyInstance } from 'fastify';
import { gamificationService } from './gamification.service.js';
import {
  leaderboardQuerySchema,
  transactionsQuerySchema,
  updateGamificationPreferencesSchema,
} from './gamification.schemas.js';

export async function gamificationRoutes(app: FastifyInstance) {
  // Public leaderboard (accessible to guests and authenticated users)
  app.get('/gamification/leaderboard', async (request, reply) => {
    const query = leaderboardQuerySchema.parse(request.query);
    let currentUserId: string | undefined;

    try {
      await request.jwtVerify();
      currentUserId = (request.user as any)?.id;
    } catch {
      // Guest mode
    }

    const leaderboard = await gamificationService.getLeaderboard(
      query.period,
      query.page,
      query.limit,
      currentUserId
    );

    return reply.status(200).send(leaderboard);
  });

  // Public levels catalog
  app.get('/gamification/levels', async (request, reply) => {
    const levels = await gamificationService.getLevels();
    return reply.status(200).send(levels);
  });

  // Protected: User gamification profile & active balance
  app.get(
    '/gamification/profile',
    { preHandler: [app.authenticate] },
    async (request, reply) => {
      const userId = (request.user as any).id;
      const profile = await gamificationService.getUserProfile(userId);
      return reply.status(200).send(profile);
    }
  );

  // Protected: Paginated transactions history
  app.get(
    '/gamification/transactions',
    { preHandler: [app.authenticate] },
    async (request, reply) => {
      const userId = (request.user as any).id;
      const query = transactionsQuerySchema.parse(request.query);
      const history = await gamificationService.getUserTransactions(
        userId,
        query.page,
        query.limit
      );
      return reply.status(200).send(history);
    }
  );

  // Protected: Update privacy preferences (LGPD)
  app.put(
    '/gamification/preferences',
    { preHandler: [app.authenticate] },
    async (request, reply) => {
      const userId = (request.user as any).id;
      const input = updateGamificationPreferencesSchema.parse(request.body);
      const profile = await gamificationService.updatePrivacyPreferences(userId, input);
      return reply.status(200).send(profile);
    }
  );
}
