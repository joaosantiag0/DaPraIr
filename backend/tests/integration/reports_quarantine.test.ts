import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { CryptoService } from '../../src/core/crypto/encryption.js';

describe('Content Reports & Automatic Quarantine Integration (US5)', () => {
  let app: FastifyInstance;
  let reporterToken1: string;
  let reporterToken2: string;
  let reporterToken3: string;
  let reviewId: string;
  let placeId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    const passwordHash = await CryptoService.hashPassword('SenhaForte123!');

    // Create 3 reporter users + 1 author
    const author = await prisma.user.create({
      data: {
        email: `author_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Autor Avaliação',
        handle: `author_${Date.now()}`,
      },
    });

    const user1 = await prisma.user.create({
      data: {
        email: `rep1_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Reporter 1',
        handle: `rep1_${Date.now()}`,
      },
    });

    const user2 = await prisma.user.create({
      data: {
        email: `rep2_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Reporter 2',
        handle: `rep2_${Date.now()}`,
      },
    });

    const user3 = await prisma.user.create({
      data: {
        email: `rep3_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Reporter 3',
        handle: `rep3_${Date.now()}`,
      },
    });

    // Create test place
    const place = await prisma.place.create({
      data: {
        name: `Restaurante Moderado ${Date.now()}`,
        category: 'RESTAURANT',
        address: 'Rua das Flores, 123',
        city: 'São Paulo',
        state: 'SP',
        latitude: -23.55052,
        longitude: -46.633308,
      },
    });
    placeId = place.id;

    // Create published review
    const review = await prisma.placeReview.create({
      data: {
        place_id: place.id,
        user_id: author.id,
        general_comment: 'Avaliação que receberá denúncias',
        average_score: 4.5,
        status: 'PUBLISHED',
      },
    });
    reviewId = review.id;

    reporterToken1 = app.jwt.sign({ id: user1.id, email: user1.email });
    reporterToken2 = app.jwt.sign({ id: user2.id, email: user2.email });
    reporterToken3 = app.jwt.sign({ id: user3.id, email: user3.email });
  });

  afterAll(async () => {
    await app.close();
  });

  it('1st report: sets review status to UNDER_REVIEW and report_count to 1', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/v1/reports',
      headers: { authorization: `Bearer ${reporterToken1}` },
      payload: {
        targetType: 'REVIEW',
        targetId: reviewId,
        reason: 'INACCURATE_DATA',
        details: 'As informações de rampa estão incorretas',
      },
    });

    expect(res.statusCode).toBe(201);
    const body = res.json();
    expect(body.distinctReportsCount).toBe(1);
    expect(body.targetStatus).toBe('UNDER_REVIEW');

    // Verify in database
    const dbReview = await prisma.placeReview.findUnique({ where: { id: reviewId } });
    expect(dbReview?.status).toBe('UNDER_REVIEW');
    expect(dbReview?.report_count).toBe(1);

    // Should still be visible in public list with UNDER_REVIEW status
    const listRes = await app.inject({
      method: 'GET',
      url: `/api/v1/places/${placeId}/reviews`,
    });
    expect(listRes.statusCode).toBe(200);
    const listBody = listRes.json();
    expect(listBody.items.some((r: any) => r.id === reviewId)).toBe(true);
  });

  it('Duplicate report by the same user is rejected (400)', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/v1/reports',
      headers: { authorization: `Bearer ${reporterToken1}` },
      payload: {
        targetType: 'REVIEW',
        targetId: reviewId,
        reason: 'SPAM',
      },
    });

    expect(res.statusCode).toBe(400);
  });

  it('2nd report by distinct user keeps review status as UNDER_REVIEW and updates count to 2', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/v1/reports',
      headers: { authorization: `Bearer ${reporterToken2}` },
      payload: {
        targetType: 'REVIEW',
        targetId: reviewId,
        reason: 'INACCURATE_DATA',
      },
    });

    expect(res.statusCode).toBe(201);
    const body = res.json();
    expect(body.distinctReportsCount).toBe(2);
    expect(body.targetStatus).toBe('UNDER_REVIEW');
  });

  it('3rd report by distinct user triggers QUARANTINED status and hides from public place reviews', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/v1/reports',
      headers: { authorization: `Bearer ${reporterToken3}` },
      payload: {
        targetType: 'REVIEW',
        targetId: reviewId,
        reason: 'HARASSMENT',
      },
    });

    expect(res.statusCode).toBe(201);
    const body = res.json();
    expect(body.distinctReportsCount).toBe(3);
    expect(body.targetStatus).toBe('QUARANTINED');

    // Verify in database
    const dbReview = await prisma.placeReview.findUnique({ where: { id: reviewId } });
    expect(dbReview?.status).toBe('QUARANTINED');
    expect(dbReview?.report_count).toBe(3);

    // Must be EXCLUDED from public reviews query (auto-quarantined)
    const listRes = await app.inject({
      method: 'GET',
      url: `/api/v1/places/${placeId}/reviews`,
    });
    expect(listRes.statusCode).toBe(200);
    const listBody = listRes.json();
    expect(listBody.items.some((r: any) => r.id === reviewId)).toBe(false);
  });

  it('GET /api/v1/reports - lists reports in moderation queue', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/reports',
      headers: { authorization: `Bearer ${reporterToken1}` },
    });

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body).toHaveProperty('reports');
    expect(body.reports.length).toBeGreaterThanOrEqual(1);
  });

  it('PATCH /api/v1/reports/:id - allows moderator to resolve and restore content', async () => {
    const listRes = await app.inject({
      method: 'GET',
      url: '/api/v1/reports',
      headers: { authorization: `Bearer ${reporterToken1}` },
    });
    const reportId = listRes.json().reports[0].id;

    const res = await app.inject({
      method: 'PATCH',
      url: `/api/v1/reports/${reportId}`,
      headers: { authorization: `Bearer ${reporterToken1}` },
      payload: {
        action: 'RESOLVE_RESTORE',
        resolutionNotes: 'Conteúdo legítimo verificado por moderador',
      },
    });

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.status).toBe('RESOLVED');
  });
});
