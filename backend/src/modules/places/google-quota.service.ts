import { config } from '../../config.js';

interface AreaSyncRecord {
  syncedAt: number;
}

interface QueryCacheRecord<T = any> {
  cachedAt: number;
  data: T;
}

export class GoogleQuotaService {
  private static instance: GoogleQuotaService;

  private dailyCount = 0;
  private currentDay = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

  // Geo-hash grid (~1.1km cell) -> timestamp (TTL: 7 days)
  private syncedAreas = new Map<string, AreaSyncRecord>();
  private readonly AREA_SYNC_TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7 days

  // Query cache -> results (TTL: 24 hours)
  private queryCache = new Map<string, QueryCacheRecord>();
  private readonly QUERY_CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

  static getInstance(): GoogleQuotaService {
    if (!GoogleQuotaService.instance) {
      GoogleQuotaService.instance = new GoogleQuotaService();
    }
    return GoogleQuotaService.instance;
  }

  private resetIfNewDay() {
    const today = new Date().toISOString().slice(0, 10);
    if (this.currentDay !== today) {
      console.log(`[Google Quota] Novo dia (${today}). Resetando contador de ${this.dailyCount} para 0.`);
      this.currentDay = today;
      this.dailyCount = 0;
    }
  }

  get dailyLimit(): number {
    return config.GOOGLE_PLACES_DAILY_LIMIT ?? 30;
  }

  get isAutoSyncEnabled(): boolean {
    return config.ENABLE_AUTO_GOOGLE_PLACES_SYNC ?? false;
  }

  /**
   * Verifica se pode fazer chamada à API sem estourar o limite diário configurado
   */
  canMakeRequest(): boolean {
    if (!config.GOOGLE_PLACES_API_KEY) return false;
    this.resetIfNewDay();

    if (this.dailyCount >= this.dailyLimit) {
      console.warn(
        `⚠️ [Google Places Quota] Limite diário de segurança atingido (${this.dailyCount}/${this.dailyLimit} requisições hoje). Usando apenas dados do banco local para proteger sua cota gratuita de 1.000 requisições.`
      );
      return false;
    }

    return true;
  }

  /**
   * Registra o consumo de uma requisição e loga o saldo restante
   */
  recordRequest(operation: string) {
    this.resetIfNewDay();
    this.dailyCount += 1;
    const remaining = Math.max(0, this.dailyLimit - this.dailyCount);
    console.log(
      `🌐 [Google Places] Chamada '${operation}' executada (${this.dailyCount}/${this.dailyLimit} hoje, restam ${remaining})`
    );
  }

  /**
   * Gera chave de grid para coordenadas arredondadas a ~1.1km
   */
  getGridKey(lat: number, lng: number): string {
    return `${lat.toFixed(2)},${lng.toFixed(2)}`;
  }

  /**
   * Verifica se a área já foi sincronizada nos últimos 7 dias
   */
  isAreaSyncedRecently(lat: number, lng: number): boolean {
    const key = this.getGridKey(lat, lng);
    const record = this.syncedAreas.get(key);
    if (!record) return false;

    const age = Date.now() - record.syncedAt;
    if (age > this.AREA_SYNC_TTL_MS) {
      this.syncedAreas.delete(key);
      return false;
    }

    return true;
  }

  /**
   * Marca uma área como sincronizada
   */
  markAreaSynced(lat: number, lng: number) {
    const key = this.getGridKey(lat, lng);
    this.syncedAreas.set(key, { syncedAt: Date.now() });
  }

  /**
   * Retorna busca textual em cache (TTL de 24h)
   */
  getCachedSearchResults<T = any>(query: string, lat?: number, lng?: number): T | null {
    const key = this.normalizeQueryKey(query, lat, lng);
    const record = this.queryCache.get(key);
    if (!record) return null;

    if (Date.now() - record.cachedAt > this.QUERY_CACHE_TTL_MS) {
      this.queryCache.delete(key);
      return null;
    }

    return record.data as T;
  }

  /**
   * Salva resultado de busca no cache por 24h
   */
  cacheSearchResults<T = any>(query: string, data: T, lat?: number, lng?: number) {
    const key = this.normalizeQueryKey(query, lat, lng);
    this.queryCache.set(key, {
      cachedAt: Date.now(),
      data,
    });
  }

  private normalizeQueryKey(query: string, lat?: number, lng?: number): string {
    const base = query.trim().toLowerCase();
    if (lat !== undefined && lng !== undefined) {
      return `${base}@${this.getGridKey(lat, lng)}`;
    }
    return base;
  }

  /**
   * Estatísticas de consumo da cota
   */
  getStats() {
    this.resetIfNewDay();
    return {
      dailyCount: this.dailyCount,
      dailyLimit: this.dailyLimit,
      remainingToday: Math.max(0, this.dailyLimit - this.dailyCount),
      currentDay: this.currentDay,
      autoSyncEnabled: this.isAutoSyncEnabled,
      cachedQueriesCount: this.queryCache.size,
      syncedAreasCount: this.syncedAreas.size,
    };
  }
}

export const googleQuotaService = GoogleQuotaService.getInstance();
