import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Privacy & LGPD API (US2)', () => {
  let app: FastifyInstance;
  let userToken: string;
  let userId: string;
  let otherUserToken: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // Create user 1
    const u1 = await prisma.user.create({
      data: {
        name: 'Ana Privacidade',
        email: 'ana_privacy@daprair.com',
        handle: 'ana_privacy_test',
        password_hash: '$argon2id$fake',
      },
    });
    userId = u1.id;
    userToken = app.jwt.sign({ id: u1.id, email: u1.email, handle: u1.handle, role: u1.role });

    // Create user 2
    const u2 = await prisma.user.create({
      data: {
        name: 'Bob Espectador',
        email: 'bob_privacy@daprair.com',
        handle: 'bob_privacy_test',
        password_hash: '$argon2id$fake',
      },
    });
    otherUserToken = app.jwt.sign({ id: u2.id, email: u2.email, handle: u2.handle, role: u2.role });
  });

  afterAll(async () => {
    await prisma.userAccessibilityProfile.deleteMany();
    await prisma.userConsent.deleteMany();
    await prisma.user.deleteMany({ where: { email: { contains: 'privacy' } } });
    await app.close();
  });

  it('PUT /api/v1/users/me/accessibility-profile - should reject if consentGranted is false (LGPD)', async () => {
    const response = await app.inject({
      method: 'PUT',
      url: '/api/v1/users/me/accessibility-profile',
      headers: { authorization: `Bearer ${userToken}` },
      payload: {
        disabilityTypes: ['WHEELCHAIR_MANUAL'],
        assistanceNeeds: ['RAMP_REQUIRED'],
        visibility: 'PRIVATE',
        consentGranted: false, // Refused
      },
    });

    expect(response.statusCode).toBe(400);
  });

  it('PUT /api/v1/users/me/accessibility-profile - should save profile and encrypt payload with consent', async () => {
    const response = await app.inject({
      method: 'PUT',
      url: '/api/v1/users/me/accessibility-profile',
      headers: { authorization: `Bearer ${userToken}` },
      payload: {
        disabilityTypes: ['WHEELCHAIR_MANUAL'],
        assistanceNeeds: ['RAMP_REQUIRED', 'ADAPTED_RESTROOM'],
        visibility: 'PRIVATE',
        consentGranted: true,
      },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.visibility).toBe('PRIVATE');
    expect(body.disabilityTypes).toContain('WHEELCHAIR_MANUAL');

    // Verify encrypted payload stored in database
    const dbProfile = await prisma.userAccessibilityProfile.findUnique({ where: { user_id: userId } });
    expect(dbProfile!.encrypted_payload).toBeDefined();
  });

  it('GET /api/v1/users/:userId - should hide private accessibility preferences from other users', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/api/v1/users/${userId}`,
      headers: { authorization: `Bearer ${otherUserToken}` },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.handle).toBe('ana_privacy_test');
    expect(body.accessibilityProfile).toBeNull(); // Hidden due to PRIVATE visibility
  });

  it('GET /api/v1/users/me/export-data - should return full portability JSON package', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/v1/users/me/export-data',
      headers: { authorization: `Bearer ${userToken}` },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.userData.handle).toBe('ana_privacy_test');
    expect(body.accessibilityProfile).toBeDefined();
    expect(body.consentLog.length).toBeGreaterThanOrEqual(1);
  });

  it('POST /api/v1/users/me/anonymize - should anonymize user account and delete health data', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/users/me/anonymize',
      headers: { authorization: `Bearer ${userToken}` },
    });

    expect(response.statusCode).toBe(200);

    const dbUser = await prisma.user.findUnique({ where: { id: userId } });
    expect(dbUser!.is_anonymous).toBe(true);
    expect(dbUser!.name).toBe('Usuário Anônimo');
    expect(dbUser!.password_hash).toBeNull();

    // Verify sensitive profile was deleted
    const profileCount = await prisma.userAccessibilityProfile.count({ where: { user_id: userId } });
    expect(profileCount).toBe(0);
  });
});
