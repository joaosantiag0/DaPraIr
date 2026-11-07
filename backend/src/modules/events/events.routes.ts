import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { eventsService } from './events.service.js';
import { z } from 'zod';

const createEventSchema = z.object({
  placeId: z.string().uuid().optional(),
  title: z.string().min(3).max(150),
  description: z.string().min(10).max(5000),
  startTime: z.string().datetime(),
  endTime: z.string().datetime(),
  locationName: z.string().min(2).max(200),
  address: z.string().min(5).max(300),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  accessibilityChecklist: z.record(z.boolean()),
  maxAttendees: z.number().int().positive().max(100000).optional(),
});

const rsvpSchema = z.object({
  status: z.enum(['CONFIRMED', 'DECLINED']).default('CONFIRMED'),
});

export async function eventsRoutes(app: FastifyInstance) {
  // Public list events (Guest mode)
  app.get(
    '/events',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { accessibilityFeature, limit = 20, offset = 0 } = request.query as any;
      const events = await eventsService.listEvents({
        accessibilityFeature,
        userId: request.user?.id,
        limit: Number(limit),
        offset: Number(offset),
      });
      return reply.status(200).send(events);
    }
  );

  // Authenticated create event
  app.post(
    '/events',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = createEventSchema.parse(request.body);
      const event = await eventsService.createEvent({
        creatorId: request.user.id,
        placeId: body.placeId,
        title: body.title,
        description: body.description,
        startTime: new Date(body.startTime),
        endTime: new Date(body.endTime),
        locationName: body.locationName,
        address: body.address,
        latitude: body.latitude,
        longitude: body.longitude,
        accessibilityChecklist: body.accessibilityChecklist,
        maxAttendees: body.maxAttendees,
      });
      return reply.status(201).send(event);
    }
  );

  // Authenticated RSVP
  app.post(
    '/events/:eventId/rsvp',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { eventId } = request.params as { eventId: string };
      const body = rsvpSchema.parse(request.body || {});
      const rsvp = await eventsService.registerRSVP(eventId, request.user.id, body.status);
      return reply.status(200).send(rsvp);
    }
  );
}
