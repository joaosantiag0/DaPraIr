import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { placesService } from './places.service.js';
import { googleQuotaService } from './google-quota.service.js';
import { z } from 'zod';

const searchPlacesQuerySchema = z.object({
  latitude: z.coerce.number().min(-90).max(90),
  longitude: z.coerce.number().min(-180).max(180),
  radiusMeters: z.coerce.number().min(50).max(50000).optional().default(5000),
  query: z.string().max(200).optional(),
  category: z.string().max(50).optional(),
  requiredCriteria: z
    .union([z.string().transform((val) => [val]), z.array(z.string().max(50))])
    .optional(),
  limit: z.coerce.number().min(1).max(100).optional().default(20),
  offset: z.coerce.number().min(0).optional().default(0),
});

const createPlaceSchema = z.object({
  name: z.string().min(2).max(200),
  description: z.string().max(3000).nullable().optional(),
  category: z.string().max(50),
  address: z.string().min(5).max(300),
  city: z.string().min(2).max(100),
  state: z.string().min(2).max(50),
  postalCode: z.string().max(20).nullable().optional(),
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  googlePlaceId: z.string().max(128).nullable().optional(),
});

export async function placesRoutes(app: FastifyInstance) {
  // Public spatial search (Guest mode supported)
  app.get('/places', async (request: FastifyRequest, reply: FastifyReply) => {
    const query = searchPlacesQuerySchema.parse(request.query);
    const result = await placesService.searchPlaces(query);
    return reply.status(200).send(result);
  });

  // Public external search (Google Places fallback)
  app.get('/places/external-search', async (request: FastifyRequest, reply: FastifyReply) => {
    const { query, latitude, longitude } = request.query as any;
    const result = await placesService.searchExternalPlaces(
      query,
      latitude ? Number(latitude) : undefined,
      longitude ? Number(longitude) : undefined
    );
    return reply.status(200).send(result);
  });

  // Google Places quota usage & status
  app.get('/places/quota-stats', async (_request: FastifyRequest, reply: FastifyReply) => {
    const stats = googleQuotaService.getStats();
    return reply.status(200).send(stats);
  });

  // Public single place detail
  app.get('/places/:placeId', async (request: FastifyRequest<{ Params: { placeId: string } }>, reply: FastifyReply) => {
    const { placeId } = request.params;
    const result = await placesService.getPlaceById(placeId);
    return reply.status(200).send(result);
  });

  // Authenticated crowdsourced place creation
  app.post(
    '/places',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = createPlaceSchema.parse(request.body);
      const place = await placesService.createPlace(body);
      return reply.status(201).send(place);
    }
  );
}
