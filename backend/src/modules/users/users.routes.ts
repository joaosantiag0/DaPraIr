import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { usersService } from './users.service.js';
import { privacyService } from './privacy.service.js';
import { z } from 'zod';

const updateProfileSchema = z.object({
  disabilityTypes: z.array(z.string()).optional(),
  assistanceNeeds: z.array(z.string()).optional(),
  visibility: z.enum(['PUBLIC', 'FRIENDS_ONLY', 'PRIVATE']),
  consentGranted: z.boolean(),
});

const updateLocationSchema = z.object({
  label: z.string(),
  address: z.string().nullable().optional(),
  city: z.string().nullable().optional(),
  state: z.string().nullable().optional(),
  latitude: z.number(),
  longitude: z.number(),
  isGps: z.boolean().optional(),
});

export async function usersRoutes(app: FastifyInstance) {
  // Get authenticated user's accessibility profile
  app.get(
    '/users/me/accessibility-profile',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const profile = await usersService.getAccessibilityProfile(request.user.id);
      return reply.status(200).send(profile);
    }
  );

  // Update accessibility profile and consent
  app.put(
    '/users/me/accessibility-profile',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = updateProfileSchema.parse(request.body);
      const profile = await usersService.updateAccessibilityProfile({
        userId: request.user.id,
        disabilityTypes: body.disabilityTypes,
        assistanceNeeds: body.assistanceNeeds,
        visibility: body.visibility,
        consentGranted: body.consentGranted,
        clientIp: request.ip,
        userAgent: request.headers['user-agent'],
      });
      return reply.status(200).send(profile);
    }
  );

  // Get encrypted user location
  app.get(
    '/users/me/location',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const location = await usersService.getUserLocation(request.user.id);
      return reply.status(200).send(location);
    }
  );

  // Update encrypted user location
  app.put(
    '/users/me/location',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = updateLocationSchema.parse(request.body);
      const result = await usersService.updateUserLocation(request.user.id, body);
      return reply.status(200).send(result);
    }
  );

  // LGPD Data Export
  app.get(
    '/users/me/export-data',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const data = await privacyService.exportUserData(request.user.id);
      return reply.status(200).send(data);
    }
  );

  // LGPD Right to be Forgotten / Anonymize (supports both DELETE and POST)
  const anonymizeHandler = async (request: FastifyRequest, reply: FastifyReply) => {
    const result = await privacyService.anonymizeAccount(request.user.id, request.ip);
    return reply.status(200).send(result);
  };

  app.delete('/users/me/anonymize', { preHandler: [app.authenticate] }, anonymizeHandler);
  app.post('/users/me/anonymize', { preHandler: [app.authenticate] }, anonymizeHandler);

  // Public user profile with granular visibility
  app.get(
    '/users/:userId',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { userId } = request.params as { userId: string };
      const viewerId = request.user?.id;
      const profile = await usersService.getPublicProfile(userId, viewerId);
      return reply.status(200).send(profile);
    }
  );
}
