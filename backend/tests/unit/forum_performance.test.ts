import { describe, it, expect, beforeAll } from 'vitest';
import { forumService } from '../../src/modules/forum/forum.service.js';
import { prisma } from '../../src/core/database/prisma.js';

describe('Forum Performance Benchmarks (P95 < 150ms)', () => {
  let testCategoryId: string;

  beforeAll(async () => {
    const category = await prisma.forumCategory.findFirst({
      where: { is_active: true },
    });
    if (category) {
      testCategoryId = category.id;
    }
  });

  it('measures P95 query response time for listCategories under load (< 150ms)', async () => {
    const iterations = 30;
    const durations: number[] = [];

    // Warmup
    await forumService.listCategories({});

    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      await forumService.listCategories({ is_active: true });
      const duration = performance.now() - start;
      durations.push(duration);
    }

    durations.sort((a, b) => a - b);
    const p95Index = Math.floor(durations.length * 0.95);
    const p95 = durations[p95Index];

    console.log(`[Benchmark] listCategories P95: ${p95.toFixed(2)}ms (samples: ${iterations})`);
    expect(p95).toBeLessThan(150);
  });

  it('measures P95 query response time for listTopics under load (< 150ms)', async () => {
    const iterations = 30;
    const durations: number[] = [];

    // Warmup
    await forumService.listTopics(undefined, {
      category_id: testCategoryId,
      limit: 20,
    });

    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      await forumService.listTopics(undefined, {
        category_id: testCategoryId,
        limit: 20,
      });
      const duration = performance.now() - start;
      durations.push(duration);
    }

    durations.sort((a, b) => a - b);
    const p95Index = Math.floor(durations.length * 0.95);
    const p95 = durations[p95Index];

    console.log(`[Benchmark] listTopics P95: ${p95.toFixed(2)}ms (samples: ${iterations})`);
    expect(p95).toBeLessThan(150);
  });
});
