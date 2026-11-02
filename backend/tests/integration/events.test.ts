import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Events API (US4 - Eventos Inclusivos)', () => {
  let app: FastifyInstance;
  let userToken: string;
  let userId: string;
  let eventId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    const u = await prisma.user.create({
      data: {
        name: 'Organizador de Evento',
        email: 'events_org@daprair.com',
        handle: 'events_organizer',
        password_hash: '$argon2id$fake',
      },
    });
    userId = u.id;
    userToken = app.jwt.sign({ id: u.id, email: u.email, handle: u.handle, role: u.role });
  });

  afterAll(async () => {
    await prisma.eventRSVP.deleteMany();
    await prisma.event.deleteMany();
    await prisma.user.deleteMany({ where: { email: { contains: 'events' } } });
    await app.close();
  });

  it('POST /api/v1/events - should reject event without declared accessibility checklist (FR-017)', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/events',
      headers: { authorization: `Bearer ${userToken}` },
      payload: {
        title: 'Encontro sem Acessibilidade Declarada',
        description: 'Descrição de teste longa com mais de dez caracteres',
        startTime: new Date(Date.now() + 86400000).toISOString(),
        endTime: new Date(Date.now() + 90000000).toISOString(),
        locationName: 'Parque Ibirapuera',
        address: 'Av. Pedro Álvares Cabral, s/n',
        accessibilityChecklist: {}, // Empty!
      },
    });

    expect(response.statusCode).toBe(400);
  });

  it('POST /api/v1/events - should create event with valid accessibility checklist', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/events',
      headers: { authorization: `Bearer ${userToken}` },
      payload: {
        title: 'Passeio Comunitário Acessível',
        description: 'Encontro para caminhada e roda de conversa sobre mobilidade',
        startTime: new Date(Date.now() + 86400000).toISOString(),
        endTime: new Date(Date.now() + 93600000).toISOString(),
        locationName: 'Parque Villa-Lobos',
        address: 'Av. Prof. Fonseca Rodrigues, 2001',
        accessibilityChecklist: {
          RAMP_REQUIRED: true,
          ADAPTED_RESTROOM: true,
          ACCESSIBLE_PARKING: true,
        },
      },
    });

    expect(response.statusCode).toBe(201);
    const body = JSON.parse(response.body);
    expect(body.title).toBe('Passeio Comunitário Acessível');
    expect(body.accessibilityChecklist.RAMP_REQUIRED).toBe(true);
    eventId = body.id;
  });

  it('GET /api/v1/events - should list events and support accessibility filtering', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/v1/events?accessibilityFeature=RAMP_REQUIRED',
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.length).toBeGreaterThanOrEqual(1);
    expect(body[0].id).toBe(eventId);
  });

  it('POST /api/v1/events/:eventId/rsvp - should register attendance and increment RSVP count', async () => {
    const response = await app.inject({
      method: 'POST',
      url: `/api/v1/events/${eventId}/rsvp`,
      headers: { authorization: `Bearer ${userToken}` },
      payload: { status: 'CONFIRMED' },
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.status).toBe('CONFIRMED');

    // Verify list reflects attendance
    const listRes = await app.inject({
      method: 'GET',
      url: '/api/v1/events',
      headers: { authorization: `Bearer ${userToken}` },
    });
    const events = JSON.parse(listRes.body);
    const ev = events.find((e: any) => e.id === eventId);
    expect(ev.rsvpCount).toBe(1);
    expect(ev.isAttending).toBe(true);
  });
});
