import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { authService } from './auth.service.js';
import { z } from 'zod';

const registerSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email().max(255),
  handle: z.string().min(3).max(30),
  password: z.string().min(8).max(128),
  acceptTermsVersion: z.string().default('1.0.0'),
});

const loginSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(1).max(128),
});

export async function authRoutes(app: FastifyInstance) {
  app.post('/auth/register', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = registerSchema.parse(request.body);
    const clientIp = request.ip || '127.0.0.1';
    const userAgent = request.headers['user-agent'];

    const user = await authService.register({
      ...body,
      clientIp,
      userAgent,
    });

    const token = app.jwt.sign({
      id: user.id,
      email: user.email,
      handle: user.handle,
      role: user.role,
    });

    return reply.status(201).send({
      user,
      token,
    });
  });

  app.post('/auth/login', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = loginSchema.parse(request.body);
    const user = await authService.login(body);

    const token = app.jwt.sign({
      id: user.id,
      email: user.email,
      handle: user.handle,
      role: user.role,
    });

    return reply.status(200).send({
      user,
      token,
    });
  });
}
