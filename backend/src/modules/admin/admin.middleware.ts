import { FastifyRequest, FastifyReply } from 'fastify';
import { prisma } from '../../core/database/prisma.js';
import { ForbiddenError, UnauthorizedError } from '../../core/errors/app-error.js';

export async function requireAdminOrModerator(request: FastifyRequest, _reply: FastifyReply) {
  // 1. Ensure user is authenticated
  if (!request.user || !request.user.id) {
    throw new UnauthorizedError('Token de autenticação inválido ou ausente');
  }

  // 2. Fetch fresh user data from DB to verify role and session status
  const user = await prisma.user.findUnique({
    where: { id: request.user.id },
    select: {
      id: true,
      role: true,
      status: true,
      session_invalidated_at: true,
    },
  });

  if (!user) {
    throw new UnauthorizedError('Usuário não encontrado');
  }

  // 3. Verify account status
  if (user.status === 'BANNED' || user.status === 'SUSPENDED') {
    throw new UnauthorizedError('Sua conta está suspensa ou banida', 'SESSION_REVOKED');
  }

  // 4. Verify token issue time against session_invalidated_at
  const tokenPayload = request.user as any;
  if (user.session_invalidated_at && tokenPayload.iat) {
    const invalidatedAtSeconds = Math.floor(user.session_invalidated_at.getTime() / 1000);
    if (tokenPayload.iat < invalidatedAtSeconds) {
      throw new UnauthorizedError('Sessão revogada. Por favor, faça login novamente', 'SESSION_REVOKED');
    }
  }

  // 5. Verify role
  if (user.role !== 'ADMIN' && user.role !== 'MODERATOR') {
    throw new ForbiddenError('Acesso restrito a administradores e moderadores');
  }

  // Synchronize decoded user role with current database role
  request.user.role = user.role;
}

export async function requireAdmin(request: FastifyRequest, _reply: FastifyReply) {
  await requireAdminOrModerator(request, _reply);
  if (request.user.role !== 'ADMIN') {
    throw new ForbiddenError('Ação restrita exclusivamente a administradores');
  }
}
