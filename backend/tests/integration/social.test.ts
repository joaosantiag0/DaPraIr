import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Social Connections API (US3)', () => {
  let app: FastifyInstance;
  let user1Token: string;
  let user1Id: string;
  let user2Token: string;
  let user2Id: string;
  let connectionId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // Create user 1
    const u1 = await prisma.user.create({
      data: {
        name: 'User Um',
        email: 'user1_social@daprair.com',
        handle: 'user1_social',
        password_hash: '$argon2id$fake',
      },
    });
    user1Id = u1.id;
    user1Token = app.jwt.sign({ id: u1.id, email: u1.email, handle: u1.handle, role: u1.role });

    // Create user 2
    const u2 = await prisma.user.create({
      data: {
        name: 'User Dois',
        email: 'user2_social@daprair.com',
        handle: 'user2_social',
        password_hash: '$argon2id$fake',
      },
    });
    user2Id = u2.id;
    user2Token = app.jwt.sign({ id: u2.id, email: u2.email, handle: u2.handle, role: u2.role });
  });

  afterAll(async () => {
    await prisma.socialConnection.deleteMany();
    await prisma.user.deleteMany({ where: { email: { contains: 'social' } } });
    await app.close();
  });

  it('POST /api/v1/social/connections - should send connection request', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/social/connections',
      headers: { authorization: `Bearer ${user1Token}` },
      payload: { targetUserId: user2Id },
    });

    expect(response.statusCode).toBe(201);
    const body = JSON.parse(response.body);
    expect(body.status).toBe('PENDING');
    expect(body.requester_id).toBe(user1Id);
    expect(body.addressee_id).toBe(user2Id);
    connectionId = body.id;
  });

  it('PATCH /api/v1/social/connections/:id - should allow recipient to accept connection', async () => {
    const response = await app.inject({
      method: 'PATCH',
      url: `/api/v1/social/connections/${connectionId}`,
      headers: { authorization: `Bearer ${user2Token}` },
      payload: { status: 'ACCEPTED' },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.status).toBe('ACCEPTED');
  });

  it('GET /api/v1/social/connections - should list accepted friends', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/v1/social/connections',
      headers: { authorization: `Bearer ${user1Token}` },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.length).toBe(1);
    expect(body[0].status).toBe('ACCEPTED');
    expect(body[0].peer.id).toBe(user2Id);
  });

  it('GET /api/v1/social/recommendations - should return peer affinity recommendations', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/v1/social/recommendations',
      headers: { authorization: `Bearer ${user1Token}` },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(Array.isArray(body)).toBe(true);
  });
});
