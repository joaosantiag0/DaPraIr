import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Chat 1:1 Security Barrier & Messaging API (US3)', () => {
  let app: FastifyInstance;
  let userAToken: string;
  let userAId: string;
  let userBToken: string;
  let userBId: string;
  let userCToken: string;
  let userCId: string;
  let connectionABId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // Create user A
    const uA = await prisma.user.create({
      data: {
        name: 'Alice Chat',
        email: 'alice_chat@daprair.com',
        handle: 'alice_chat',
        password_hash: '$argon2id$fake',
      },
    });
    userAId = uA.id;
    userAToken = app.jwt.sign({ id: uA.id, email: uA.email, handle: uA.handle, role: uA.role });

    // Create user B
    const uB = await prisma.user.create({
      data: {
        name: 'Bob Chat',
        email: 'bob_chat@daprair.com',
        handle: 'bob_chat',
        password_hash: '$argon2id$fake',
      },
    });
    userBId = uB.id;
    userBToken = app.jwt.sign({ id: uB.id, email: uB.email, handle: uB.handle, role: uB.role });

    // Create stranger user C (not friend)
    const uC = await prisma.user.create({
      data: {
        name: 'Carlos Estranho',
        email: 'carlos_stranger@daprair.com',
        handle: 'carlos_stranger',
        password_hash: '$argon2id$fake',
      },
    });
    userCId = uC.id;
    userCToken = app.jwt.sign({ id: uC.id, email: uC.email, handle: uC.handle, role: uC.role });
  });

  afterAll(async () => {
    await prisma.directMessage.deleteMany();
    await prisma.socialConnection.deleteMany();
    await prisma.user.deleteMany({ where: { email: { contains: 'chat' } } });
    await prisma.user.deleteMany({ where: { email: { contains: 'stranger' } } });
    await app.close();
  });

  it('POST /api/v1/chat/messages/:peerUserId - should enforce 403 Forbidden for non-friends (Anti-harassment barrier)', async () => {
    const response = await app.inject({
      method: 'POST',
      url: `/api/v1/chat/messages/${userAId}`,
      headers: { authorization: `Bearer ${userCToken}` },
      payload: { content: 'Oi, tudo bem? Mensagem de estranho' },
    });

    expect(response.statusCode).toBe(403);
    const body = JSON.parse(response.body);
    expect(body.message).toContain('amigos aceitos');
  });

  it('POST /api/v1/chat/messages/:peerUserId - should allow messaging after connection is ACCEPTED', async () => {
    // Establish accepted friendship between A and B
    const conn = await prisma.socialConnection.create({
      data: {
        requester_id: userAId,
        addressee_id: userBId,
        status: 'ACCEPTED',
      },
    });
    connectionABId = conn.id;

    const response = await app.inject({
      method: 'POST',
      url: `/api/v1/chat/messages/${userBId}`,
      headers: { authorization: `Bearer ${userAToken}` },
      payload: { content: 'Olá Bob! Você conhece a acessibilidade do parque Ibirapuera?' },
    });

    expect(response.statusCode).toBe(201);
    const body = JSON.parse(response.body);
    expect(body.content).toContain('parque Ibirapuera');
    expect(body.status).toBe('SENT');
  });

  it('GET /api/v1/chat/messages/:peerUserId - should retrieve chat history between accepted friends', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/api/v1/chat/messages/${userAId}`,
      headers: { authorization: `Bearer ${userBToken}` },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.length).toBe(1);
    expect(body[0].content).toContain('parque Ibirapuera');
  });

  it('POST /api/v1/chat/messages/:peerUserId - should revoke chat access immediately after blocking user', async () => {
    // Block connection
    await prisma.socialConnection.update({
      where: { id: connectionABId },
      data: { status: 'BLOCKED' },
    });

    const response = await app.inject({
      method: 'POST',
      url: `/api/v1/chat/messages/${userBId}`,
      headers: { authorization: `Bearer ${userAToken}` },
      payload: { content: 'Tentativa de mensagem após bloqueio' },
    });

    expect(response.statusCode).toBe(403);
  });
});
