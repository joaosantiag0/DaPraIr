import fastifyPlugin from 'fastify-plugin';
import fastifyJwt from '@fastify/jwt';
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { config } from '../../config.js';
import { UnauthorizedError } from '../errors/app-error.js';

declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
    optionalAuthenticate: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: { id: string; email: string; role: string; handle: string };
    user: { id: string; email: string; role: string; handle: string };
  }
}

import { prisma } from '../database/prisma.js';

export const jwtPlugin = fastifyPlugin(async (fastify: FastifyInstance) => {
  await fastify.register(fastifyJwt, {
    secret: config.JWT_SECRET,
    sign: {
      expiresIn: '7d',
    },
  });

  fastify.decorate('authenticate', async (request: FastifyRequest, _reply: FastifyReply) => {
    try {
      await request.jwtVerify();
    } catch {
      throw new UnauthorizedError('Token de autenticação inválido ou ausente');
    }

    // Verify fresh account status and session validity in database
    const user = await prisma.user.findUnique({
      where: { id: request.user.id },
      select: { id: true, role: true, status: true, session_invalidated_at: true },
    });

    if (!user) {
      throw new UnauthorizedError('Usuário não encontrado');
    }

    if (user.status === 'BANNED' || user.status === 'SUSPENDED' || user.status === 'DELETED') {
      throw new UnauthorizedError('Sua conta está suspensa, banida ou inativa', 'SESSION_REVOKED');
    }

    const tokenPayload = request.user as any;
    if (user.session_invalidated_at && tokenPayload.iat) {
      const invalidatedAtSeconds = Math.floor(user.session_invalidated_at.getTime() / 1000);
      if (tokenPayload.iat < invalidatedAtSeconds) {
        throw new UnauthorizedError('Sessão revogada. Por favor, faça login novamente', 'SESSION_REVOKED');
      }
    }

    // Synchronize JWT role with database role
    request.user.role = user.role;
  });

  fastify.decorate('optionalAuthenticate', async (request: FastifyRequest, _reply: FastifyReply) => {
    try {
      if (request.headers.authorization) {
        await request.jwtVerify();
        const user = await prisma.user.findUnique({
          where: { id: request.user.id },
          select: { id: true, role: true, status: true, session_invalidated_at: true },
        });

        if (user && user.status === 'ACTIVE') {
          const tokenPayload = request.user as any;
          if (
            !user.session_invalidated_at ||
            !tokenPayload.iat ||
            tokenPayload.iat >= Math.floor(user.session_invalidated_at.getTime() / 1000)
          ) {
            request.user.role = user.role;
            return;
          }
        }
        // If user is suspended, banned, or session is revoked, treat as unauthenticated guest
        delete (request as any).user;
      }
    } catch {
      // Guest mode - silence token validation failure
      delete (request as any).user;
    }
  });
});
