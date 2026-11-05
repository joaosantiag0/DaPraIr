import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Auth API (US2 - Inclusão e Autenticação)', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();
  });

  afterAll(async () => {
    await prisma.userConsent.deleteMany();
    await prisma.user.deleteMany({ where: { email: { contains: 'authtest' } } });
    await app.close();
  });

  it('POST /api/v1/auth/register - should register user, hash password with Argon2id and log LGPD consents', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Carlos Oliveira',
        email: 'carlos_authtest@daprair.com',
        handle: 'carlos_oliveira_test',
        password: 'Password123!',
        acceptTermsVersion: '1.0.0',
      },
    });

    expect(response.statusCode).toBe(201);
    const body = JSON.parse(response.body);
    expect(body.user.email).toBe('carlos_authtest@daprair.com');
    expect(body.user.handle).toBe('carlos_oliveira_test');
    expect(body.token).toBeDefined();

    // Verify password hash is Argon2id
    const dbUser = await prisma.user.findUnique({ where: { email: 'carlos_authtest@daprair.com' } });
    expect(dbUser!.password_hash?.startsWith('$argon2id$')).toBe(true);

    // Verify LGPD consents logged
    const consents = await prisma.userConsent.findMany({ where: { user_id: dbUser!.id } });
    expect(consents.length).toBe(2); // TERMS_OF_SERVICE and PRIVACY_POLICY
  });

  it('POST /api/v1/auth/register - should reject duplicate email with 409 Conflict', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Carlos Duplicate',
        email: 'carlos_authtest@daprair.com',
        handle: 'carlos_diff_handle',
        password: 'Password123!',
        acceptTermsVersion: '1.0.0',
      },
    });

    expect(response.statusCode).toBe(409);
  });

  it('POST /api/v1/auth/login - should authenticate user with correct password', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/login',
      payload: {
        email: 'carlos_authtest@daprair.com',
        password: 'Password123!',
      },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.token).toBeDefined();
    expect(body.user.handle).toBe('carlos_oliveira_test');
  });

  it('POST /api/v1/auth/login - should reject invalid password with 401', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/login',
      payload: {
        email: 'carlos_authtest@daprair.com',
        password: 'WrongPassword!',
      },
    });

    expect(response.statusCode).toBe(401);
  });

  it('POST /api/v1/auth/register - should automatically elevate user to ADMIN if email matches ADMIN_EMAILS', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Admin Test',
        email: 'admin@daprair.com',
        handle: 'admin_daprair_test',
        password: 'Password123!',
        acceptTermsVersion: '1.0.0',
      },
    });

    expect(response.statusCode).toBe(201);
    const body = JSON.parse(response.body);
    expect(body.user.email).toBe('admin@daprair.com');
    expect(body.user.role).toBe('ADMIN');

    const dbUser = await prisma.user.findUnique({ where: { email: 'admin@daprair.com' } });
    expect(dbUser?.role).toBe('ADMIN');

    // Clean up
    await prisma.userConsent.deleteMany({ where: { user_id: dbUser!.id } });
    await prisma.user.delete({ where: { id: dbUser!.id } });
  });
});

