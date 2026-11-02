import Fastify, { FastifyInstance } from 'fastify';
import fastifyCors from '@fastify/cors';
import fastifyMultipart from '@fastify/multipart';
import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUi from '@fastify/swagger-ui';
import fastifyWebsocket from '@fastify/websocket';
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

export async function buildApp(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: config.NODE_ENV === 'test' ? false : { level: 'info' },
  });

  // CORS
  await app.register(fastifyCors, {
    origin: true,
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
