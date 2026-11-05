import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { CryptoService } from '../../src/core/crypto/encryption.js';

describe('Security Audit Suite - DáPraIr?', () => {
  let app: FastifyInstance;
  let regularUserToken: string;
  let moderatorToken: string;
  let adminToken: string;
  let victimUserToken: string;
  let regularUserId: string;
  let victimUserId: string;
  let testPlaceId: string;
  let victimTopicId: string;
  let victimCommentId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    const passwordHash = await CryptoService.hashPassword('StrongPass123!');

    // 1. Regular User
    const regUser = await prisma.user.create({
      data: {
        email: `sec_reg_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Regular User',
        handle: `sec_reg_${Date.now()}`,
        role: 'USER',
      },
    });
    regularUserId = regUser.id;
    regularUserToken = app.jwt.sign({
      id: regUser.id,
      email: regUser.email,
      role: regUser.role,
      handle: regUser.handle,
    });

    // 2. Moderator
    const modUser = await prisma.user.create({
      data: {
        email: `sec_mod_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Moderator User',
        handle: `sec_mod_${Date.now()}`,
        role: 'MODERATOR',
      },
    });
    moderatorToken = app.jwt.sign({
      id: modUser.id,
      email: modUser.email,
      role: modUser.role,
      handle: modUser.handle,
    });

    // 3. Admin
    const admUser = await prisma.user.create({
      data: {
        email: `sec_adm_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Admin User',
        handle: `sec_adm_${Date.now()}`,
        role: 'ADMIN',
      },
    });
    adminToken = app.jwt.sign({
      id: admUser.id,
      email: admUser.email,
      role: admUser.role,
      handle: admUser.handle,
    });

    // 4. Victim User
    const victim = await prisma.user.create({
      data: {
        email: `sec_vic_${Date.now()}@test.com`,
        password_hash: passwordHash,
        name: 'Victim User',
        handle: `sec_vic_${Date.now()}`,
        role: 'USER',
      },
    });
    victimUserId = victim.id;
    victimUserToken = app.jwt.sign({
      id: victim.id,
      email: victim.email,
      role: victim.role,
      handle: victim.handle,
    });

    // Test place
    const place = await prisma.place.create({
      data: {
        name: `Local Seguro ${Date.now()}`,
        category: 'PARK',
        address: 'Av. Paulista, 1500',
        city: 'São Paulo',
        state: 'SP',
        latitude: -23.561,
        longitude: -46.655,
      },
    });
    testPlaceId = place.id;

    // Test category & victim forum topic
    const cat = await prisma.forumCategory.create({
      data: {
        name: `Categoria Sec ${Date.now()}`,
        slug: `cat-sec-${Date.now()}`,
        description: 'Test category',
        icon_name: 'shield',
      },
    });

    const topic = await prisma.forumTopic.create({
      data: {
        category_id: cat.id,
        author_id: victimUserId,
        title: 'Tópico da Vítima',
        content: 'Conteúdo original que não deve ser alterado por outros',
        visibility: 'PUBLIC',
        status: 'ACTIVE',
      },
    });
    victimTopicId = topic.id;

    const comment = await prisma.forumComment.create({
      data: {
        topic_id: topic.id,
        author_id: victimUserId,
        content: 'Comentário original da vítima',
        visibility: 'PUBLIC',
        status: 'ACTIVE',
      },
    });
    victimCommentId = comment.id;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('1. Static File Serving & Path Traversal Prevention', () => {
    it('blocks path traversal using absolute path escape (/uploads//etc/hosts)', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/uploads//etc/hosts',
      });

      // Must be 403 Forbidden, never 200 OK streaming hosts
      expect(res.statusCode).toBe(403);
      expect(res.body).not.toContain('localhost');
    });

    it('blocks path traversal using absolute path escape (/uploads//package.json)', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/uploads//package.json',
      });

      // Must be 403 Forbidden, never 200 OK
      expect(res.statusCode).toBe(403);
      expect(res.body).not.toContain('"name": "daprair-backend"');
    });

    it('blocks directory traversal using ../ sequences in uploads', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/uploads/../../package.json',
      });

      expect([400, 403, 404]).toContain(res.statusCode);
      expect(res.body).not.toContain('"name": "daprair-backend"');
    });
  });

  describe('2. Broken Function Level Authorization (RBAC) on Moderation', () => {
    it('rejects regular USER from listing moderation reports (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/api/v1/reports',
        headers: { authorization: `Bearer ${regularUserToken}` },
      });

      expect(res.statusCode).toBe(403);
    });

    it('rejects regular USER from resolving moderation reports (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'PATCH',
        url: '/api/v1/reports/00000000-0000-0000-0000-000000000000',
        headers: { authorization: `Bearer ${regularUserToken}` },
        payload: {
          action: 'RESOLVE_REMOVE',
          resolutionNotes: 'Tentativa de moderação ilegítima',
        },
      });

      expect(res.statusCode).toBe(403);
    });

    it('allows MODERATOR or ADMIN to list moderation reports', async () => {
      const resMod = await app.inject({
        method: 'GET',
        url: '/api/v1/reports',
        headers: { authorization: `Bearer ${moderatorToken}` },
      });
      expect(resMod.statusCode).toBe(200);

      const resAdm = await app.inject({
        method: 'GET',
        url: '/api/v1/reports',
        headers: { authorization: `Bearer ${adminToken}` },
      });
      expect(resAdm.statusCode).toBe(200);
    });
  });

  describe('3. Media Upload Validation & Directory Traversal Prevention', () => {
    it('rejects invalid or traversal placeId in multipart upload', async () => {
      // Mock multipart boundary
      const boundary = '----WebKitFormBoundarySecurityTest';
      const payload = [
        `--${boundary}`,
        'Content-Disposition: form-data; name="placeId"',
        '',
        '../../../../etc',
        `--${boundary}`,
        'Content-Disposition: form-data; name="altText"',
        '',
        'Rampa de acesso frontal com corrimão',
        `--${boundary}`,
        'Content-Disposition: form-data; name="file"; filename="test.jpg"',
        'Content-Type: image/jpeg',
        '',
        'fake-jpg-content',
        `--${boundary}--`,
      ].join('\r\n');

      const res = await app.inject({
        method: 'POST',
        url: '/api/v1/media/upload',
        headers: {
          authorization: `Bearer ${regularUserToken}`,
          'content-type': `multipart/form-data; boundary=${boundary}`,
        },
        payload,
      });

      expect(res.statusCode).toBe(400);
      expect(res.json().message).toMatch(/placeId inválido|UUID/i);
    });
  });

  describe('4. DoS Protection & Password Bounds on Registration', () => {
    it('rejects excessively large passwords (>128 chars) to protect Argon2id CPU resources', async () => {
      const giantPassword = 'A'.repeat(5000);
      const res = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/register',
        payload: {
          name: 'Attacker DoS',
          email: `dos_${Date.now()}@test.com`,
          handle: `dos_${Date.now()}`,
          password: giantPassword,
        },
      });

      expect(res.statusCode).toBe(400);
    });
  });

  describe('5. IDOR & Ownership Verification on Forum', () => {
    it('prevents attacker from editing victims forum topic (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'PATCH',
        url: `/api/v1/forum/topics/${victimTopicId}`,
        headers: { authorization: `Bearer ${regularUserToken}` },
        payload: {
          title: 'Título hackeado!',
          content: 'Conteúdo adulterado!',
        },
      });

      expect(res.statusCode).toBe(403);
    });

    it('prevents attacker from deleting victims forum topic (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'DELETE',
        url: `/api/v1/forum/topics/${victimTopicId}`,
        headers: { authorization: `Bearer ${regularUserToken}` },
      });

      expect(res.statusCode).toBe(403);
    });

    it('prevents attacker from editing victims forum comment (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'PATCH',
        url: `/api/v1/forum/comments/${victimCommentId}`,
        headers: { authorization: `Bearer ${regularUserToken}` },
        payload: {
          content: 'Comentário adulterado pelo atacante',
        },
      });

      expect(res.statusCode).toBe(403);
    });

    it('prevents attacker from deleting victims forum comment (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'DELETE',
        url: `/api/v1/forum/comments/${victimCommentId}`,
        headers: { authorization: `Bearer ${regularUserToken}` },
      });

      expect(res.statusCode).toBe(403);
    });
  });

  describe('6. Chat 1:1 Security Barrier (Anti-BOLA / IDOR)', () => {
    it('blocks messaging between unapproved strangers (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'POST',
        url: `/api/v1/chat/messages/${victimUserId}`,
        headers: { authorization: `Bearer ${regularUserToken}` },
        payload: {
          content: 'Olá vítima, mensagem não solicitada',
        },
      });

      expect(res.statusCode).toBe(403);
      expect(res.json().message).toMatch(/amigos aceitos/i);
    });

    it('blocks reading messages between unapproved strangers (403 Forbidden)', async () => {
      const res = await app.inject({
        method: 'GET',
        url: `/api/v1/chat/messages/${victimUserId}`,
        headers: { authorization: `Bearer ${regularUserToken}` },
      });

      expect(res.statusCode).toBe(403);
    });
  });

  describe('7. Automatic Quarantine on Forum Reports', () => {
    it('sets FORUM_TOPIC to REMOVED_BY_ADMIN (quarantined) when 3 distinct reports are submitted', async () => {
      // Create a topic to report
      const cat = await prisma.forumCategory.findFirst();
      const testTopic = await prisma.forumTopic.create({
        data: {
          category_id: cat!.id,
          author_id: victimUserId,
          title: 'Tópico com Discurso Tóxico',
          content: 'Conteúdo ofensivo que precisa de quarentena',
          visibility: 'PUBLIC',
          status: 'ACTIVE',
        },
      });

      // Submit 3 reports by 3 distinct users
      const rep1 = await app.inject({
        method: 'POST',
        url: '/api/v1/reports',
        headers: { authorization: `Bearer ${regularUserToken}` },
        payload: {
          targetType: 'FORUM_TOPIC',
          targetId: testTopic.id,
          reason: 'HARASSMENT',
        },
      });
      expect(rep1.statusCode).toBe(201);
      expect(rep1.json().distinctReportsCount).toBe(1);

      const rep2 = await app.inject({
        method: 'POST',
        url: '/api/v1/reports',
        headers: { authorization: `Bearer ${moderatorToken}` },
        payload: {
          targetType: 'FORUM_TOPIC',
          targetId: testTopic.id,
          reason: 'SPAM',
        },
      });
      expect(rep2.statusCode).toBe(201);
      expect(rep2.json().distinctReportsCount).toBe(2);

      const rep3 = await app.inject({
        method: 'POST',
        url: '/api/v1/reports',
        headers: { authorization: `Bearer ${adminToken}` },
        payload: {
          targetType: 'FORUM_TOPIC',
          targetId: testTopic.id,
          reason: 'INAPPROPRIATE_MEDIA',
        },
      });
      expect(rep3.statusCode).toBe(201);
      expect(rep3.json().distinctReportsCount).toBe(3);
      expect(rep3.json().targetStatus).toBe('QUARANTINED');

      // Verify in DB that status is now REMOVED_BY_ADMIN
      const dbTopic = await prisma.forumTopic.findUnique({ where: { id: testTopic.id } });
      expect(dbTopic?.status).toBe('REMOVED_BY_ADMIN');

      // Verify excluded from public list
      const listRes = await app.inject({
        method: 'GET',
        url: '/api/v1/forum/topics',
      });
      expect(listRes.statusCode).toBe(200);
      expect(listRes.json().some((t: any) => t.id === testTopic.id)).toBe(false);
    });
  });

  describe('8. HTTP Security Headers (Helmet)', () => {
    it('sets protective security headers on HTTP responses', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/health',
      });

      expect(res.headers['x-content-type-options']).toBe('nosniff');
      expect(res.headers['x-frame-options']).toBe('SAMEORIGIN');
    });
  });
});
