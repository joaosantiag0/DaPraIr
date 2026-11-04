import { describe, it, expect, beforeEach } from 'vitest';
import { googleQuotaService } from '../../src/modules/places/google-quota.service.js';

describe('GoogleQuotaService Unit Tests', () => {
  it('should return initial stats with configured daily limit', () => {
    const stats = googleQuotaService.getStats();
    expect(stats).toBeDefined();
    expect(stats.dailyLimit).toBeGreaterThan(0);
    expect(stats.remainingToday).toBeLessThanOrEqual(stats.dailyLimit);
    expect(typeof stats.autoSyncEnabled).toBe('boolean');
  });

  it('should correctly calculate grid key for ~1.1km cells', () => {
    const key1 = googleQuotaService.getGridKey(-22.88581, -48.44502);
    const key2 = googleQuotaService.getGridKey(-22.88589, -48.44509);
    expect(key1).toBe('-22.89,-48.45');
    expect(key2).toBe('-22.89,-48.45');
    expect(key1).toBe(key2);
  });

  it('should mark area as synced and recognize it recently', () => {
    const lat = -22.8858;
    const lng = -48.4450;
    expect(googleQuotaService.isAreaSyncedRecently(lat, lng)).toBe(false);

    googleQuotaService.markAreaSynced(lat, lng);
    expect(googleQuotaService.isAreaSyncedRecently(lat, lng)).toBe(true);
  });

  it('should cache and retrieve search results to avoid duplicate Google API calls', () => {
    const query = 'Farmacia Botucatu';
    const mockResults = [{ googlePlaceId: 'gp_123', name: 'Farmacia Teste' }];

    expect(googleQuotaService.getCachedSearchResults(query)).toBeNull();

    googleQuotaService.cacheSearchResults(query, mockResults);
    const retrieved = googleQuotaService.getCachedSearchResults<typeof mockResults>(query);
    expect(retrieved).toEqual(mockResults);
  });

  it('should record requests and update remaining balance', () => {
    const initialStats = googleQuotaService.getStats();
    const countBefore = initialStats.dailyCount;

    googleQuotaService.recordRequest('test_unit');
    const newStats = googleQuotaService.getStats();

    expect(newStats.dailyCount).toBe(countBefore + 1);
    expect(newStats.remainingToday).toBe(Math.max(0, newStats.dailyLimit - newStats.dailyCount));
  });
});
