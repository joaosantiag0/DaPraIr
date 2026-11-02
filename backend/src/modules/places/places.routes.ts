import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { placesService } from './places.service.js';
import { z } from 'zod';

const searchPlacesQuerySchema = z.object({
  latitude: z.coerce.number(),
  longitude: z.coerce.number(),
  radiusMeters: z.coerce.number().optional().default(5000),
  query: z.string().optional(),
  category: z.string().optional(),
  requiredCriteria: z
    .union([z.string().transform((val) => [val]), z.array(z.string())])
    .optional(),
  limit: z.coerce.number().optional().default(20),
  offset: z.coerce.number().optional().default(0),
});

const createPlaceSchema = z.object({
  name: z.string().min(2),
  description: z.string().optional(),
  category: z.string(),
  address: z.string().min(5),
  city: z.string().min(2),
  state: z.string().min(2),
  postalCode: z.string().optional(),
  latitude: z.number(),
  longitude: z.number(),
  googlePlaceId: z.string().optional(),
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
