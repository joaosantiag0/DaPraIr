import { describe, it, expect, beforeAll } from 'vitest';
import fs from 'node:fs';
import path from 'node:path';
import { buildApp } from '../../src/server.js';
import { FastifyInstance } from 'fastify';

describe('Forum OpenAPI Contract Compliance Tests', () => {
  let app: FastifyInstance;
  let openapiYaml: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    const specPath = path.resolve(
      process.cwd(),
      '../specs/002-forum-topics-discussions/contracts/openapi.yaml'
    );
    openapiYaml = fs.readFileSync(specPath, 'utf8');
  });

  it('contract file exists and contains all required forum endpoints', () => {
    expect(openapiYaml).toBeDefined();
    const requiredPaths = [
      '/forum/categories',
      '/forum/categories/{id}',
      '/forum/topics',
      '/forum/topics/{id}',
      '/forum/topics/{id}/like',
      '/forum/topics/{id}/comments',
      '/forum/comments/{id}',
      '/forum/comments/{id}/like',
    ];

    for (const p of requiredPaths) {
      expect(openapiYaml).toContain(p);
    }
  });

  it('verifies Fastify router registers all forum contract routes', async () => {
    // Test that each endpoint is registered (returns something other than 404 route not found)
    const routesToTest = [
      { method: 'GET' as const, url: '/api/v1/forum/categories' },
      { method: 'GET' as const, url: '/api/v1/forum/topics' },
      { method: 'POST' as const, url: '/api/v1/forum/topics' },
      { method: 'POST' as const, url: '/api/v1/forum/reports' },
    ];

    for (const r of routesToTest) {
      const res = await app.inject({ method: r.method, url: r.url });
      expect(res.statusCode).not.toBe(404);
    }
  });

  it('validates GET /forum/categories response structure against ForumCategory schema', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/forum/categories',
    });

    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.body);
    expect(Array.isArray(body)).toBe(true);

    if (body.length > 0) {
      const category = body[0];
      expect(category).toHaveProperty('id');
      expect(category).toHaveProperty('name');
      expect(category).toHaveProperty('slug');
      expect(category).toHaveProperty('description');
      expect(category).toHaveProperty('icon_name');
      expect(category).toHaveProperty('topics_count');
      expect(category).toHaveProperty('is_active');
    }
  });
});
