import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { chatService } from './chat.service.js';
import { chatWsManager } from './chat.websocket.js';
import { prisma } from '../../core/database/prisma.js';
import { z } from 'zod';

const sendMessageSchema = z.object({
  content: z.string().min(1).max(2000),
});

export async function chatRoutes(app: FastifyInstance) {
  // Get chat history with peer
  app.get(
    '/chat/messages/:peerUserId',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { peerUserId } = request.params as { peerUserId: string };
      const { limit = 50, offset = 0 } = request.query as any;
      const messages = await chatService.getMessages(
        request.user.id,
        peerUserId,
        Number(limit),
        Number(offset)
      );
      return reply.status(200).send(messages);
    }
  );

  // Send 1:1 message
  app.post(
    '/chat/messages/:peerUserId',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { peerUserId } = request.params as { peerUserId: string };
      const body = sendMessageSchema.parse(request.body);

      const message = await chatService.sendMessage({
        senderId: request.user.id,
        recipientId: peerUserId,
        content: body.content,
      });

      // Dispatch via real-time WebSocket if recipient is connected
      chatWsManager.sendToUser(peerUserId, {
        type: 'NEW_MESSAGE',
        message,
      });

      return reply.status(201).send(message);
    }
  );

  // Real-time WebSocket connection
  app.get('/chat/ws', { websocket: true }, async (connection, req) => {
    const ws = ((connection as any).socket ?? connection) as any;
    const token = (req.query as any)?.token;
    if (!token) {
      ws.close(1008, 'Token ausente');
      return;
    }

    try {
      const decoded = app.jwt.verify<{ id: string; iat?: number }>(token);
      const user = await prisma.user.findUnique({
        where: { id: decoded.id },
        select: { status: true, session_invalidated_at: true },
      });

      if (!user || user.status !== 'ACTIVE') {
        ws.close(1008, 'Conta inativa ou suspensa');
        return;
      }

      if (user.session_invalidated_at && decoded.iat) {
        const invalidatedAtSeconds = Math.floor(user.session_invalidated_at.getTime() / 1000);
        if (decoded.iat < invalidatedAtSeconds) {
          ws.close(1008, 'Sessão revogada');
          return;
        }
      }

      chatWsManager.registerSocket(decoded.id, ws);
    } catch {
      ws.close(1008, 'Token inválido');
    }
  });
}
