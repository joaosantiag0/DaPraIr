import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { prisma } from '../../src/core/database/prisma.js';
import { gamificationService } from '../../src/modules/gamification/gamification.service.js';

describe('GamificationService Unit Tests', () => {
  let testUser1Id: string;
  let testUser2Id: string;

  beforeAll(async () => {
    // Seed levels if not seeded
    const levels = [
      { id: 'EXPLORER', name: 'Explorador', min_points: 0, level_order: 1, description: 'Nível 1' },
      { id: 'COLLABORATOR', name: 'Colaborador', min_points: 100, level_order: 2, description: 'Nível 2' },
      { id: 'MAPPER', name: 'Mapeador', min_points: 300, level_order: 3, description: 'Nível 3' },
      { id: 'SPECIALIST', name: 'Especialista', min_points: 700, level_order: 4, description: 'Nível 4' },
      { id: 'AMBASSADOR', name: 'Embaixador', min_points: 1500, level_order: 5, description: 'Nível 5' },
    ];
    for (const lvl of levels) {
      await prisma.gamificationLevel.upsert({
        where: { id: lvl.id },
        update: {},
        create: lvl,
      });
    }

    const u1 = await prisma.user.upsert({
      where: { email: 'gamif_user1@daprair.com' },
      update: {},
      create: {
        email: 'gamif_user1@daprair.com',
        name: 'Gamif User 1',
        handle: 'gamif_u1',
      },
    });
    testUser1Id = u1.id;

    const u2 = await prisma.user.upsert({
      where: { email: 'gamif_user2@daprair.com' },
      update: {},
      create: {
        email: 'gamif_user2@daprair.com',
        name: 'Gamif User 2',
        handle: 'gamif_u2',
      },
    });
    testUser2Id = u2.id;
  });

  afterAll(async () => {
    await prisma.gamificationTransaction.deleteMany({
      where: { user_id: { in: [testUser1Id, testUser2Id] } },
    });
    await prisma.userGamificationProfile.deleteMany({
      where: { user_id: { in: [testUser1Id, testUser2Id] } },
    });
    await prisma.user.deleteMany({
      where: { id: { in: [testUser1Id, testUser2Id] } },
    });
  });

  it('initializes profile at EXPLORER with 0 points', async () => {
    const profile = await gamificationService.getUserProfile(testUser1Id);
    expect(profile.points_total).toBe(0);
    expect(profile.current_level.id).toBe('EXPLORER');
    expect(profile.points_to_next_level).toBe(100);
  });

  it('awards points and promotes level progressively', async () => {
    const fakeReviewId = '00000000-0000-0000-0000-000000000099';
    await gamificationService.awardPoints({
      userId: testUser1Id,
      actionType: 'AVALIACAO_LOCAL',
      points: 120,
      sourceId: fakeReviewId,
      sourceType: 'REVIEW',
      description: 'Avaliação inicial com bônus',
    });

    const updated = await gamificationService.getUserProfile(testUser1Id);
    expect(updated.points_total).toBe(120);
    expect(updated.current_level.id).toBe('COLLABORATOR');
    expect(updated.points_to_next_level).toBe(180); // 300 - 120
  });

  it('enforces idempotency on duplicate transaction attempts', async () => {
    const fakeReviewId = '00000000-0000-0000-0000-000000000099';
    // Re-award with exact same userId, actionType, sourceId
    await gamificationService.awardPoints({
      userId: testUser1Id,
      actionType: 'AVALIACAO_LOCAL',
      points: 120,
      sourceId: fakeReviewId,
      sourceType: 'REVIEW',
      description: 'Tentativa duplicada',
    });

    const profile = await gamificationService.getUserProfile(testUser1Id);
    expect(profile.points_total).toBe(120); // Not doubled
  });

  it('rolls back points on content removal', async () => {
    const fakeSource = '00000000-0000-0000-0000-000000000088';
    await gamificationService.awardPoints({
      userId: testUser2Id,
      actionType: 'TOPICO_FORUM',
      points: 10,
      sourceId: fakeSource,
      sourceType: 'FORUM_TOPIC',
      description: 'Tópico no fórum',
    });

    let p2 = await gamificationService.getUserProfile(testUser2Id);
    expect(p2.points_total).toBe(10);

    await gamificationService.rollbackPoints(testUser2Id, fakeSource, 'Violação de regras');
    p2 = await gamificationService.getUserProfile(testUser2Id);
    expect(p2.points_total).toBe(0);
  });
});
