import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Admin Routes Integration Tests (RBAC & Moderation Endpoints)', () => {
  let app: FastifyInstance;
  let adminToken: string;
  let moderatorToken: string;
  let regularUserToken: string;
  let adminId: string;
  let regularUserId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // 1. Create test admin user
    const adminUser = await prisma.user.upsert({
      where: { email: 'admin_test@daprair.com' },
      update: { role: 'ADMIN', status: 'ACTIVE', session_invalidated_at: null },
      create: {
        email: 'admin_test@daprair.com',
        name: 'Admin Test User',
        handle: 'admin_test_user',
        role: 'ADMIN',
        status: 'ACTIVE',
      },
    });
    adminId = adminUser.id;
    adminToken = app.jwt.sign({
      id: adminUser.id,
      email: adminUser.email,
      role: adminUser.role,
      handle: adminUser.handle,
    });

    // 2. Create test moderator user
    const moderatorUser = await prisma.user.upsert({
      where: { email: 'moderator_test@daprair.com' },
      update: { role: 'MODERATOR', status: 'ACTIVE', session_invalidated_at: null },
      create: {
        email: 'moderator_test@daprair.com',
        name: 'Moderator Test User',
        handle: 'mod_test_user',
        role: 'MODERATOR',
        status: 'ACTIVE',
      },
    });
    moderatorToken = app.jwt.sign({
      id: moderatorUser.id,
      email: moderatorUser.email,
      role: moderatorUser.role,
      handle: moderatorUser.handle,
    });

    // 3. Create regular user
    const regularUser = await prisma.user.upsert({
      where: { email: 'regular_user_test@daprair.com' },
      update: { role: 'USER', status: 'ACTIVE', session_invalidated_at: null },
      create: {
        email: 'regular_user_test@daprair.com',
        name: 'Regular Test User',
        handle: 'regular_test_user',
        role: 'USER',
        status: 'ACTIVE',
      },
    });
    regularUserId = regularUser.id;
    regularUserToken = app.jwt.sign({
      id: regularUser.id,
      email: regularUser.email,
      role: regularUser.role,
      handle: regularUser.handle,
    });
  });

  afterAll(async () => {
    await app.close();
  });

  describe('RBAC & Security Guards', () => {
    it('returns 401 Unauthorized when no token is supplied', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/admin/dashboard/stats',
      });

      expect(response.statusCode).toBe(401);
    });

    it('returns 403 Forbidden when a regular user attempts admin access', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/admin/dashboard/stats',
        headers: {
          authorization: `Bearer ${regularUserToken}`,
        },
      });

      expect(response.statusCode).toBe(403);
    });

    it('returns 401 with SESSION_REVOKED when user token is invalidated', async () => {
      // Invalidate regular user session
      await prisma.user.update({
        where: { id: regularUserId },
        data: {
          status: 'BANNED',
          session_invalidated_at: new Date(),
        },
      });

      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/admin/dashboard/stats',
        headers: {
          authorization: `Bearer ${regularUserToken}`,
        },
      });

      expect(response.statusCode).toBe(401);
      const body = response.json();
      expect(body.code).toBe('SESSION_REVOKED');

      // Reset regular user status
      await prisma.user.update({
        where: { id: regularUserId },
        data: { status: 'ACTIVE', session_invalidated_at: null },
      });
    });
  });

  describe('Admin Dashboard Stats', () => {
    it('returns 200 OK with dashboard stats for Admin', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/admin/dashboard/stats',
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data).toHaveProperty('pendingReportsCount');
      expect(data).toHaveProperty('actionsTodayCount');
      expect(data).toHaveProperty('activePenaltiesCount');
      expect(data).toHaveProperty('totalUsersCount');
    });
  });

  describe('User Story 1: Reports Management', () => {
    let testReportId: string;

    beforeAll(async () => {
      const report = await prisma.contentReport.create({
        data: {
          reporter_id: regularUserId,
          target_type: 'USER',
          target_id: regularUserId,
          reason: 'SPAM',
          details: 'Envio de mensagens automatizadas repetidas',
          status: 'PENDING',
        },
      });
      testReportId = report.id;
    });

    it('returns list of reports with pagination', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/admin/reports?limit=10',
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data).toHaveProperty('items');
      expect(data).toHaveProperty('total');
      expect(Array.isArray(data.items)).toBe(true);
    });

    it('returns detailed report info by ID', async () => {
      const response = await app.inject({
        method: 'GET',
        url: `/api/v1/admin/reports/${testReportId}`,
        headers: {
          authorization: `Bearer ${moderatorToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data.id).toBe(testReportId);
      expect(data.reason).toBe('SPAM');
      expect(data.reporterMaskedName).toBeDefined();
    });

    it('resolves report with valid justification', async () => {
      const response = await app.inject({
        method: 'PATCH',
        url: `/api/v1/admin/reports/${testReportId}`,
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
        payload: {
          action: 'DISMISS_UNFOUNDED',
          resolutionNotes: 'Denúncia analisada e considerada improcedente após verificação.',
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data.status).toBe('DISMISSED');
    });
  });

  describe('User Story 2: Unified Content Moderation', () => {
    let testTopicId: string;
    let testCategoryId: string;

    beforeAll(async () => {
      const category = await prisma.forumCategory.upsert({
        where: { slug: 'admin-test-cat' },
        update: {},
        create: {
          name: 'Admin Test Category',
          slug: 'admin-test-cat',
          description: 'Category for admin tests',
          icon_name: 'shield',
        },
      });
      testCategoryId = category.id;

      const topic = await prisma.forumTopic.create({
        data: {
          category_id: testCategoryId,
          author_id: regularUserId,
          title: 'Tópico de Teste para Moderação Admin',
          content: 'Conteúdo do tópico de teste para ocultação e exclusão em cascata.',
          status: 'ACTIVE',
        },
      });
      testTopicId = topic.id;

      // Add child comment
      await prisma.forumComment.create({
        data: {
          topic_id: topic.id,
          author_id: regularUserId,
          content: 'Comentário filho subordinado ao tópico.',
          status: 'ACTIVE',
        },
      });
    });

    it('lists unified content matching search filter', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/admin/content?type=FORUM_TOPIC&query=Moderação',
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data.items.length).toBeGreaterThanOrEqual(1);
      expect(data.items[0].type).toBe('FORUM_TOPIC');
    });

    it('hides content and cascades to child comments', async () => {
      const response = await app.inject({
        method: 'PATCH',
        url: `/api/v1/admin/content/FORUM_TOPIC/${testTopicId}/hide`,
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
        payload: {
          reason: 'Conteúdo ocultado temporariamente para averiguação de fatos.',
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data.newStatus).toBe('HIDDEN');
      expect(data.cascadeCount).toBe(1);

      // Verify DB status
      const updatedTopic = await prisma.forumTopic.findUnique({ where: { id: testTopicId } });
      expect(updatedTopic?.status).toBe('HIDDEN_BY_ADMIN');

      const updatedComment = await prisma.forumComment.findFirst({ where: { topic_id: testTopicId } });
      expect(updatedComment?.status).toBe('HIDDEN_BY_ADMIN');
    });

    it('restores content back to ACTIVE', async () => {
      const response = await app.inject({
        method: 'PATCH',
        url: `/api/v1/admin/content/FORUM_TOPIC/${testTopicId}/restore`,
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
        payload: {
          reason: 'Conteúdo regularizado e restaurado para circulação pública.',
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data.newStatus).toBe('ACTIVE');

      const updatedTopic = await prisma.forumTopic.findUnique({ where: { id: testTopicId } });
      expect(updatedTopic?.status).toBe('ACTIVE');
    });

    it('deletes content with cascade and double confirmation', async () => {
      const response = await app.inject({
        method: 'DELETE',
        url: `/api/v1/admin/content/FORUM_TOPIC/${testTopicId}`,
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
        payload: {
          reason: 'Exclusão permanente por violação crítica dos termos de serviço.',
          confirm: true,
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data.newStatus).toBe('REMOVED');
      expect(data.cascadeCount).toBe(1);

      const updatedTopic = await prisma.forumTopic.findUnique({ where: { id: testTopicId } });
      expect(updatedTopic?.status).toBe('REMOVED_BY_ADMIN');
    });
  });

  describe('User Story 3: User Sanctions & Progressive Penalties', () => {
    let testPenaltyId: string;

    it('applies a 7-day suspension to user and invalidates session', async () => {
      const response = await app.inject({
        method: 'POST',
        url: `/api/v1/admin/users/${regularUserId}/penalties`,
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
        payload: {
          penaltyType: 'SUSPENSION_7_DAYS',
          reason: 'Reincidência de conduta abusiva em debates comunitários.',
        },
      });

      expect(response.statusCode).toBe(201);
      const data = response.json();
      expect(data.penaltyType).toBe('SUSPENSION_7_DAYS');
      expect(data.endsAt).toBeDefined();
      testPenaltyId = data.id;

      // Verify user has status SUSPENDED and session_invalidated_at set
      const user = await prisma.user.findUnique({ where: { id: regularUserId } });
      expect(user?.status).toBe('SUSPENDED');
      expect(user?.session_invalidated_at).toBeDefined();
    });

    it('revokes user penalty and re-activates account', async () => {
      const response = await app.inject({
        method: 'DELETE',
        url: `/api/v1/admin/users/${regularUserId}/penalties/${testPenaltyId}`,
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
        payload: {
          reason: 'Recurso aceito pela administração após retratação formal.',
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data.status).toBe('ACTIVE');
    });
  });

  describe('User Story 4: Audit Logs', () => {
    it('retrieves chronological list of moderation audit actions', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/admin/audit-logs?limit=10',
        headers: {
          authorization: `Bearer ${adminToken}`,
        },
      });

      expect(response.statusCode).toBe(200);
      const data = response.json();
      expect(data).toHaveProperty('items');
      expect(data.items.length).toBeGreaterThan(0);
      expect(data.items[0]).toHaveProperty('moderatorName');
      expect(data.items[0]).toHaveProperty('actionType');
      expect(data.items[0]).toHaveProperty('reason');
    });
  });
});
