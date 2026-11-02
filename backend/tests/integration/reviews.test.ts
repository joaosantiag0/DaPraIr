import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Reviews API (US1 - Multicriteria Reviews & Auditing)', () => {
  let app: FastifyInstance;
  let testUserToken: string;
  let testUserId: string;
  let testPlaceId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // Create test user
    const testUser = await prisma.user.upsert({
      where: { email: 'reviews_test@daprair.com' },
      update: {},
      create: {
        email: 'reviews_test@daprair.com',
        name: 'Reviewer Test User',
        handle: 'reviewer_test_user',
        password_hash: '$argon2id$v=19$m=19456,t=2,p=1$fakehash',
      },
    });
    testUserId = testUser.id;

    testUserToken = app.jwt.sign({
      id: testUser.id,
      email: testUser.email,
      role: testUser.role,
      handle: testUser.handle,
    });

    // Create test place
    const place = await prisma.place.create({
      data: {
        name: 'Livraria Acessível',
        category: 'SHOPPING',
        address: 'Rua das Letras, 50',
        city: 'Campinas',
        state: 'SP',
        latitude: -22.9064,
        longitude: -47.0616,
      },
    });
    testPlaceId = place.id;
  });

  afterAll(async () => {
    await prisma.placeReviewRating.deleteMany({ where: { review: { place_id: testPlaceId } } });
    await prisma.placeReview.deleteMany({ where: { place_id: testPlaceId } });
    await prisma.placeMedia.deleteMany({ where: { place_id: testPlaceId } });
    await prisma.place.deleteMany({ where: { id: testPlaceId } });
    await prisma.user.deleteMany({ where: { email: 'reviews_test@daprair.com' } });
    await app.close();
  });

  it('POST /api/v1/places/:placeId/reviews - should reject review without ratings', async () => {
    const response = await app.inject({
      method: 'POST',
      url: `/api/v1/places/${testPlaceId}/reviews`,
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        generalComment: 'Sem notas',
        ratings: [],
      },
    });

    expect(response.statusCode).toBe(400);
  });

  it('POST /api/v1/places/:placeId/reviews - should reject invalid rating score (e.g. 6)', async () => {
    const response = await app.inject({
      method: 'POST',
      url: `/api/v1/places/${testPlaceId}/reviews`,
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        generalComment: 'Nota inválida',
        ratings: [{ criterionCode: 'ENTRANCE_RAMP_LEVEL', score: 6 }],
      },
    });

    expect(response.statusCode).toBe(400);
  });

  it('POST /api/v1/places/:placeId/reviews - should publish multicriteria review and update place score', async () => {
    const response = await app.inject({
      method: 'POST',
      url: `/api/v1/places/${testPlaceId}/reviews`,
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        generalComment: 'Excelente rampa e banheiro adaptado espaçoso!',
        ratings: [
          { criterionCode: 'ENTRANCE_RAMP_LEVEL', score: 5, notes: 'Rampa larga antiderrapante' },
          { criterionCode: 'ADAPTED_BATHROOM', score: 4, notes: 'Barra lateral firme' },
        ],
      },
    });

    expect(response.statusCode).toBe(201);
    const body = JSON.parse(response.body);
    expect(body.placeId).toBe(testPlaceId);
    expect(body.averageScore).toBe(4.5); // (5 + 4) / 2
    expect(body.status).toBe('PUBLISHED');
    expect(body.ratings.length).toBe(2);

    // Verify place overall score updated in database
    const updatedPlace = await prisma.place.findUnique({ where: { id: testPlaceId } });
    expect(Number(updatedPlace!.overall_score)).toBe(4.5);
    expect(updatedPlace!.total_reviews).toBe(1);
    expect(updatedPlace!.last_reviewed_at).toBeDefined();
  });

  it('GET /api/v1/places/:placeId/reviews - should allow guest to list published reviews', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/api/v1/places/${testPlaceId}/reviews`,
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.total).toBe(1);
    expect(body.items[0].averageScore).toBe(4.5);
    expect(body.items[0].author.handle).toBe('@reviewer_test_user');
  });

  it('POST /api/v1/media/upload-url - should enforce mandatory alt_text with min 5 characters', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/media/upload-url',
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        placeId: testPlaceId,
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
        altText: 'Foto', // Too short (< 5 chars)
      },
    });

    expect(response.statusCode).toBe(400);
  });
});
