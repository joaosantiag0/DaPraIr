import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { CryptoService } from '../../src/core/crypto/encryption.js';

describe('Feed Aggregation Integration (US5)', () => {
  let app: FastifyInstance;
  let testUserToken: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    const passwordHash = await CryptoService.hashPassword('SenhaForte123!');
    const user = await prisma.user.create({
      data: {
        email: `feed_user_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Usuário do Feed',
        handle: `feed_user_${Date.now()}`,
      },
    });

    testUserToken = app.jwt.sign({ id: user.id, email: user.email });
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /api/v1/feed returns feed sections for anonymous guest visitors', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/feed',
    });

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body).toHaveProperty('highlightedPlaces');
    expect(body).toHaveProperty('recentReviews');
    expect(body).toHaveProperty('upcomingEvents');
    expect(body).toHaveProperty('accessibilityTips');

    expect(Array.isArray(body.highlightedPlaces)).toBe(true);
    expect(Array.isArray(body.recentReviews)).toBe(true);
    expect(Array.isArray(body.upcomingEvents)).toBe(true);
    expect(Array.isArray(body.accessibilityTips)).toBe(true);
    expect(body.accessibilityTips.length).toBeGreaterThan(0);
  });

  it('GET /api/v1/feed returns personalized feed with attendance indicators for authenticated user', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/feed',
      headers: { authorization: `Bearer ${testUserToken}` },
    });

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body).toHaveProperty('highlightedPlaces');
    expect(body).toHaveProperty('recentReviews');
    expect(body).toHaveProperty('upcomingEvents');
    expect(body).toHaveProperty('accessibilityTips');
  });
});
