import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Places API (US1 - Descoberta e Avaliação de Locais)', () => {
  let app: FastifyInstance;
  let testUserToken: string;
  let testPlaceId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // Create test user and token
    const testUser = await prisma.user.upsert({
      where: { email: 'places_test@daprair.com' },
      update: {},
      create: {
        email: 'places_test@daprair.com',
        name: 'Test Place Reviewer',
        handle: 'places_test_reviewer',
        password_hash: '$argon2id$v=19$m=19456,t=2,p=1$fakehash',
      },
    });

    testUserToken = app.jwt.sign({
      id: testUser.id,
      email: testUser.email,
      role: testUser.role,
      handle: testUser.handle,
    });

    // Create test place
    const place = await prisma.place.create({
      data: {
        name: 'Restaurante Acessível Centro',
        category: 'RESTAURANT',
        address: 'Rua das Flores, 123',
        city: 'São Paulo',
        state: 'SP',
        latitude: -23.55052,
        longitude: -46.633308,
        overall_score: 4.5,
        total_reviews: 2,
        source: 'COMMUNITY',
      },
    });
    testPlaceId = place.id;
  });

  afterAll(async () => {
    await prisma.place.deleteMany({ where: { city: 'São Paulo' } });
    await prisma.user.deleteMany({ where: { email: 'places_test@daprair.com' } });
    await app.close();
  });

  it('GET /api/v1/places - should allow unauthenticated guest to search places by GPS coordinates', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/v1/places?latitude=-23.55052&longitude=-46.633308&radiusMeters=5000',
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.total).toBeGreaterThanOrEqual(1);
    expect(body.items[0]).toHaveProperty('id');
    expect(body.items[0]).toHaveProperty('overallScore');
    expect(body.items[0]).toHaveProperty('criteriaBreakdown');
    expect(body.items[0]).toHaveProperty('distanceMeters');
  });

  it('GET /api/v1/places/:placeId - should return place details with 7 criteria and outdated badge calculation', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/api/v1/places/${testPlaceId}`,
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.id).toBe(testPlaceId);
    expect(body.name).toBe('Restaurante Acessível Centro');
    expect(body.isOutdated).toBe(false); // Null or recent
    expect(Array.isArray(body.criteriaBreakdown)).toBe(true);
    expect(body.criteriaBreakdown.length).toBe(7); // 7 Standard criteria
  });

  it('POST /api/v1/places - should reject unauthenticated attempt to create place with 401', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/places',
      payload: {
        name: 'Novo Café Acessível',
        category: 'BAR',
        address: 'Av Paulista, 500',
        city: 'São Paulo',
        state: 'SP',
        latitude: -23.56,
        longitude: -46.65,
      },
    });

    expect(response.statusCode).toBe(401);
  });

  it('POST /api/v1/places - should allow authenticated user to create crowdsourced place', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/places',
      headers: {
        authorization: `Bearer ${testUserToken}`,
      },
      payload: {
        name: 'Museu Acessível Paulista',
        category: 'PARK',
        address: 'Av Paulista, 1578',
        city: 'São Paulo',
        state: 'SP',
        latitude: -23.5614,
        longitude: -46.6565,
      },
    });

    expect(response.statusCode).toBe(201);
    const body = JSON.parse(response.body);
    expect(body.name).toBe('Museu Acessível Paulista');
    expect(body.source).toBe('COMMUNITY');
  });

  it('GET /api/v1/places/external-search - should search external Google Places fallback', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/v1/places/external-search?query=Teatro%20Municipal',
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(Array.isArray(body)).toBe(true);
    expect(body[0]).toHaveProperty('googlePlaceId');
    expect(body[0].name).toBe('Teatro Municipal');
  });
});
