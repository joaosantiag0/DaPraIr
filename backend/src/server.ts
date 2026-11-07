import Fastify, { FastifyInstance } from 'fastify';
import fastifyCors from '@fastify/cors';
import fastifyHelmet from '@fastify/helmet';
import fastifyRateLimit from '@fastify/rate-limit';
import fastifyMultipart from '@fastify/multipart';
import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUi from '@fastify/swagger-ui';
import fastifyWebsocket from '@fastify/websocket';
import fs from 'node:fs';
import path from 'node:path';
import { config } from './config.js';
import { sensiblePlugin } from './core/plugins/sensible.js';
import { jwtPlugin } from './core/plugins/jwt.js';
import { placesRoutes } from './modules/places/places.routes.js';
import { reviewsRoutes } from './modules/reviews/reviews.routes.js';
import { mediaRoutes } from './modules/media/media.routes.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { usersRoutes } from './modules/users/users.routes.js';
import { socialRoutes } from './modules/social/social.routes.js';
import { chatRoutes } from './modules/chat/chat.routes.js';
import { eventsRoutes } from './modules/events/events.routes.js';
import { reportsRoutes } from './modules/reports/reports.routes.js';
import { feedRoutes } from './modules/feed/feed.routes.js';
import { forumRoutes } from './modules/forum/forum.routes.js';
import { gamificationRoutes } from './modules/gamification/gamification.routes.js';
import { adminRoutes } from './modules/admin/admin.routes.js';

export async function buildApp(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: config.NODE_ENV === 'test' ? false : { level: 'info' },
  });

  // Security HTTP Headers (CSP, HSTS, X-Content-Type-Options, etc.)
  await app.register(fastifyHelmet, {
    contentSecurityPolicy: config.NODE_ENV === 'production' ? undefined : false,
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  });

  // Rate Limiting (Brute-force & DoS protection)
  await app.register(fastifyRateLimit, {
    max: config.NODE_ENV === 'test' ? 10000 : 300,
    timeWindow: '1 minute',
  });

  // CORS
  await app.register(fastifyCors, {
    origin: (origin, cb) => {
      // In test or development without origin header, allow
      if (config.NODE_ENV !== 'production' || !origin) {
        return cb(null, true);
      }
      const allowed = process.env.CORS_ALLOWED_ORIGINS
        ? process.env.CORS_ALLOWED_ORIGINS.split(',').map((o) => o.trim())
        : [];
      if (allowed.length === 0 || allowed.includes(origin)) {
        return cb(null, true);
      }
      return cb(new Error('Origem não permitida pela política CORS'), false);
    },
    credentials: true,
  });

  // Multipart upload (up to 10MB)
  await app.register(fastifyMultipart, {
    limits: {
      fileSize: 10 * 1024 * 1024,
    },
  });

  // WebSocket support
  await app.register(fastifyWebsocket);

  // Core sensible error handling & JWT
  await app.register(sensiblePlugin);
  await app.register(jwtPlugin);

  // Support empty JSON bodies for requests with Content-Type: application/json (e.g. toggle likes)
  app.addContentTypeParser(
    'application/json',
    { parseAs: 'string' },
    (req, body: string | Buffer, done) => {
      const raw = typeof body === 'string' ? body : (body ? (body as Buffer).toString('utf-8') : '');
      if (!raw || raw.trim() === '') {
        return done(null, {});
      }
      try {
        return done(null, JSON.parse(raw));
      } catch (err: any) {
        err.statusCode = 400;
        return done(err, undefined);
      }
    }
  );

  // Swagger Documentation
  await app.register(fastifySwagger, {
    openapi: {
      info: {
        title: 'DáPraIr? API',
        description: 'Plataforma Comunitária e Social de Acessibilidade Física',
        version: '1.0.0',
      },
      servers: [
        {
          url: `http://localhost:${config.PORT}`,
          description: 'Local development server',
        },
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
          },
        },
      },
    },
  });

  await app.register(fastifySwaggerUi, {
    routePrefix: '/docs',
    uiConfig: {
      docExpansion: 'list',
      deepLinking: false,
    },
  });

  // Health check
  app.get('/health', async () => {
    return {
      status: 'ok',
      service: 'daprair-backend',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    };
  });

  // Serve static uploaded media
  app.get('/uploads/*', async (request, reply) => {
    const rawPath = (request.params as any)['*'] || '';
    const uploadsDir = path.resolve(process.cwd(), 'uploads');

    // Reject traversal patterns immediately with 403 Forbidden
    if (rawPath.startsWith('/') || rawPath.startsWith('\\') || rawPath.includes('..')) {
      return reply.status(403).send({ message: 'Acesso proibido: tentativa de travessia de caminho' });
    }

    const fullPath = path.resolve(uploadsDir, rawPath);

    // Strict boundary enforcement: fullPath must reside strictly inside uploadsDir
    if (!fullPath.startsWith(uploadsDir + path.sep)) {
      return reply.status(403).send({ message: 'Acesso proibido: tentativa de travessia de caminho' });
    }

    if (!fs.existsSync(fullPath) || fs.statSync(fullPath).isDirectory()) {
      return reply.status(404).send({ message: 'Arquivo não encontrado' });
    }
    const ext = path.extname(fullPath).toLowerCase();
    const mimeMap: Record<string, string> = {
      '.webp': 'image/webp',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
    };
    reply.header('Content-Type', mimeMap[ext] || 'application/octet-stream');
    reply.header('Cache-Control', 'public, max-age=31536000, immutable');
    return reply.send(fs.createReadStream(fullPath));
  });

  // API Routes (prefix: /api/v1)
  await app.register(
    async (api) => {
      await api.register(authRoutes);
      await api.register(usersRoutes);
      await api.register(socialRoutes);
      await api.register(chatRoutes);
      await api.register(eventsRoutes);
      await api.register(reportsRoutes);
      await api.register(feedRoutes);
      await api.register(placesRoutes);
      await api.register(reviewsRoutes);
      await api.register(mediaRoutes);
      await api.register(forumRoutes);
      await api.register(gamificationRoutes);
      await api.register(adminRoutes);
    },
    { prefix: '/api/v1' }
  );

  return app;
}

async function start() {
  const app = await buildApp();
  try {
    const address = await app.listen({ port: config.PORT, host: config.HOST });
    app.log.info(`🚀 DáPraIr? Backend running on ${address}`);
    app.log.info(`📖 Swagger documentation at ${address}/docs`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

if (process.env.NODE_ENV !== 'test') {
  start();
}
