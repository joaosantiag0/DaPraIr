import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Gamification Routes Integration Tests', () => {
  let app: FastifyInstance;
  let testUserToken: string;
  let testUserId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // Ensure levels
    const levels = [
      { id: 'EXPLORER', name: 'Explorador', min_points: 0, level_order: 1, description: 'Nível 1' },
      { id: 'COLLABORATOR', name: 'Colaborador', min_points: 100, level_order: 2, description: 'Nível 2' },
      { id: 'MAPPER', name: 'Mapeador', min_points: 300, level_order: 3, description: 'Nível 3' },
    ];
    for (const lvl of levels) {
      await prisma.gamificationLevel.upsert({
        where: { id: lvl.id },
        update: {},
        create: lvl,
      });
    }

    const user = await prisma.user.upsert({
      where: { email: 'gamif_routes_user@daprair.com' },
      update: {},
      create: {
        email: 'gamif_routes_user@daprair.com',
        name: 'Gamif Routes User',
        handle: 'gamif_routes_u',
      },
    });
    testUserId = user.id;

    testUserToken = app.jwt.sign({
      id: user.id,
      email: user.email,
      role: user.role,
      handle: user.handle,
    });
  });

  afterAll(async () => {
    await prisma.gamificationTransaction.deleteMany({
      where: { user_id: testUserId },
    });
    await prisma.userGamificationProfile.deleteMany({
      where: { user_id: testUserId },
    });
    await prisma.user.deleteMany({
      where: { id: testUserId },
    });
    await app.close();
  });

  it('GET /api/v1/gamification/levels returns levels catalog', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/gamification/levels',
    });
    expect(res.statusCode).toBe(200);
    const json = JSON.parse(res.payload);
    expect(Array.isArray(json)).toBe(true);
    expect(json.length).toBeGreaterThanOrEqual(3);
  });

  it('GET /api/v1/gamification/profile requires authentication', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/gamification/profile',
    });
    expect(res.statusCode).toBe(401);
  });

  it('GET /api/v1/gamification/profile returns profile with valid JWT', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/gamification/profile',
      headers: {
        Authorization: `Bearer ${testUserToken}`,
      },
    });
    expect(res.statusCode).toBe(200);
    const json = JSON.parse(res.payload);
    expect(json.current_level).toBeDefined();
    expect(json.is_ranking_visible).toBe(true);
  });

  it('GET /api/v1/gamification/leaderboard works for guests without auth', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/gamification/leaderboard?period=all_time',
    });
    expect(res.statusCode).toBe(200);
    const json = JSON.parse(res.payload);
    expect(json.period).toBe('all_time');
    expect(Array.isArray(json.leaderboard)).toBe(true);
  });

  it('PUT /api/v1/gamification/preferences updates privacy settings (LGPD)', async () => {
    const res = await app.inject({
      method: 'PUT',
      url: '/api/v1/gamification/preferences',
      headers: {
        Authorization: `Bearer ${testUserToken}`,
      },
      payload: {
        is_ranking_visible: false,
        use_anonymous_nickname: true,
        custom_nickname: 'Cidadão Oculto',
      },
    });
    expect(res.statusCode).toBe(200);
    const json = JSON.parse(res.payload);
    expect(json.is_ranking_visible).toBe(false);
    expect(json.use_anonymous_nickname).toBe(true);
    expect(json.custom_nickname).toBe('Cidadão Oculto');
  });
});
