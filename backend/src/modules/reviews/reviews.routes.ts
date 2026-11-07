import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { reviewsService } from './reviews.service.js';
import { z } from 'zod';

const createReviewSchema = z.object({
  generalComment: z.string().max(3000).nullable().optional(),
  ratings: z
    .array(
      z.object({
        criterionCode: z.string().max(50),
        score: z.number().int().min(1).max(5),
        notes: z.string().max(1000).nullable().optional(),
      })
    )
    .min(1)
    .max(20),
  mediaIds: z.array(z.string().uuid()).max(10).nullable().optional(),
});

export async function reviewsRoutes(app: FastifyInstance) {
  // Public list reviews for place (Guest mode)
  app.get(
    '/places/:placeId/reviews',
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { placeId } = request.params as { placeId: string };
      const { limit = 10, offset = 0 } = request.query as any;
      const result = await reviewsService.listReviewsForPlace(
        placeId,
        Number(limit),
        Number(offset)
      );
      return reply.status(200).send(result);
    }
  );

  // Authenticated create review
  app.post(
    '/places/:placeId/reviews',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { placeId } = request.params as { placeId: string };
      const body = createReviewSchema.parse(request.body);
      const review = await reviewsService.createReview({
        placeId,
        userId: request.user.id,
        generalComment: body.generalComment,
        ratings: body.ratings,
        mediaIds: body.mediaIds,
      });
      return reply.status(201).send(review);
    }
  );
}
