import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { socialService } from './social.service.js';
import { z } from 'zod';

const createConnectionSchema = z.object({
  targetUserId: z.string().uuid(),
});

const updateConnectionSchema = z.object({
  status: z.enum(['ACCEPTED', 'DECLINED', 'BLOCKED']),
});

export async function socialRoutes(app: FastifyInstance) {
  // List connections and pending requests
  app.get(
    '/social/connections',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const connections = await socialService.getConnections(request.user.id);
      return reply.status(200).send(connections);
    }
  );

  // Send connection request
  app.post(
    '/social/connections',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = createConnectionSchema.parse(request.body);
      const connection = await socialService.sendRequest(request.user.id, body.targetUserId);
      return reply.status(201).send(connection);
    }
  );

  // Accept, decline, or block connection
  app.patch(
    '/social/connections/:id',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const body = updateConnectionSchema.parse(request.body);
      const connection = await socialService.updateStatus(request.user.id, id, body.status);
      return reply.status(200).send(connection);
    }
  );

  // Get peer affinity recommendations
  app.get(
    '/social/recommendations',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const recommendations = await socialService.getRecommendations(request.user.id);
      return reply.status(200).send(recommendations);
    }
  );
}
