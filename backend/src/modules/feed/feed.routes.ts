import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { feedService } from './feed.service.js';

export async function feedRoutes(app: FastifyInstance) {
  // Community Feed (public for guest, personalized for authenticated)
  app.get(
    '/feed',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { latitude, longitude, limit = 10 } = request.query as any;

      const feed = await feedService.getFeed({
        userId: request.user?.id,
        latitude: latitude ? Number(latitude) : undefined,
        longitude: longitude ? Number(longitude) : undefined,
        limit: Number(limit),
      });

      return reply.status(200).send(feed);
    }
  );
}
