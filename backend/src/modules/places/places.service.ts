import { prisma } from '../../core/database/prisma.js';
import { Prisma } from '@prisma/client';
import { NotFoundError, BadRequestError } from '../../core/errors/app-error.js';
import { Client } from '@googlemaps/google-maps-services-js';
import { config } from '../../config.js';
import { googleQuotaService } from './google-quota.service.js';

export interface SearchPlacesParams {
  latitude: number;
  longitude: number;
  radiusMeters?: number;
  query?: string;
  category?: string;
  requiredCriteria?: string[];
  limit?: number;
  offset?: number;
}

export interface CreatePlaceDTO {
  name: string;
  description?: string | null;
  category: string;
  address: string;
  city: string;
  state: string;
  postalCode?: string | null;
  latitude: number;
  longitude: number;
  googlePlaceId?: string | null;
}

export class PlacesService {
  private googleMapsClient = new Client({});

  private extractCityAndState(formattedAddress: string): { city: string; state: string } {
    try {
      const parts = formattedAddress.split(',').map((p) => p.trim());
      for (const part of parts) {
        const match = part.match(/(.+?)\s*-\s*([A-Z]{2})\b/i);
        if (match) {
          return {
            city: match[1].trim(),
            state: match[2].toUpperCase().trim(),
          };
        }
      }
    } catch {}
    return { city: 'São Paulo', state: 'SP' };
  }

  private mapGoogleCategory(types?: string[]): string {
    if (!types || types.length === 0) return 'Restaurante';
    if (types.includes('restaurant') || types.includes('food')) return 'Restaurante';
    if (types.includes('cafe') || types.includes('bakery')) return 'Café';
    if (types.includes('bar') || types.includes('night_club')) return 'Bar';
    if (types.includes('park') || types.includes('campground')) return 'Parque';
    if (types.includes('museum') || types.includes('art_gallery')) return 'Museu';
    if (types.includes('store') || types.includes('shopping_mall') || types.includes('supermarket')) return 'Comércio';
    if (types.includes('hospital') || types.includes('doctor') || types.includes('pharmacy') || types.includes('health')) return 'Saúde';
    if (types.includes('lodging') || types.includes('hotel')) return 'Hotel';
    if (types.includes('movie_theater') || types.includes('theater')) return 'Cultura';
    return 'Outro';
  }

  /**
   * Automatically fetch nearby places from Google Places and cache them in local DB
   */
  async syncGooglePlacesNearby(
    latitude: number,
    longitude: number,
    radiusMeters = 3000,
    query?: string,
    category?: string
  ): Promise<{ targetLat?: number; targetLng?: number } | null> {
    if (!config.GOOGLE_PLACES_API_KEY) return null;

    // Check quota before initiating any Google Places API calls
    if (!googleQuotaService.canMakeRequest()) {
      return null;
    }

    try {
      if (query && query.trim().length > 0) {
        const externalItems = await this.searchExternalPlaces(query.trim(), latitude, longitude);
        if (externalItems && externalItems.length > 0) {
          for (const item of externalItems) {
            const existing = await prisma.place.findUnique({
              where: { google_place_id: item.googlePlaceId },
            });

            if (!existing) {
              const { city, state } = this.extractCityAndState(item.formattedAddress);
              await prisma.place.create({
                data: {
                  name: item.name,
                  category: item.category,
                  address: item.formattedAddress,
                  city,
                  state,
                  latitude: item.latitude,
                  longitude: item.longitude,
                  google_place_id: item.googlePlaceId,
                  source: 'GOOGLE_PLACES',
                  overall_score: 0.0,
                  total_reviews: 0,
                },
              });
            }
          }
          return {
            targetLat: externalItems[0].latitude,
            targetLng: externalItems[0].longitude,
          };
        }
      } else {
        // If checking purely nearby coordinates without a query:
        // 1. Verify 7-day geo-cache
        if (googleQuotaService.isAreaSyncedRecently(latitude, longitude)) {
          return { targetLat: latitude, targetLng: longitude };
        }

        googleQuotaService.recordRequest('placesNearby_sync');
        googleQuotaService.markAreaSynced(latitude, longitude);

        const response = await this.googleMapsClient.placesNearby({
          params: {
            location: { lat: latitude, lng: longitude },
            radius: Math.min(radiusMeters, 5000),
            key: config.GOOGLE_PLACES_API_KEY,
            language: 'pt-BR' as any,
          },
        });
        const results = response.data.results || [];

        for (const item of results) {
          if (!item.place_id || !item.name) continue;
          const lat = item.geometry?.location?.lat;
          const lng = item.geometry?.location?.lng;
          if (lat === undefined || lng === undefined) continue;

          const address = item.vicinity || item.formatted_address || `${item.name}, São Paulo, SP`;
          const placeCategory = category || this.mapGoogleCategory(item.types);
          const { city, state } = this.extractCityAndState(address);

          const existing = await prisma.place.findUnique({
            where: { google_place_id: item.place_id },
          });

          if (!existing) {
            await prisma.place.create({
              data: {
                name: item.name,
                category: placeCategory,
                address,
                city,
                state,
                latitude: lat,
                longitude: lng,
                google_place_id: item.place_id,
                source: 'GOOGLE_PLACES',
                overall_score: 0.0,
                total_reviews: 0,
              },
            });
          }
        }
        return { targetLat: latitude, targetLng: longitude };
      }
    } catch (e: any) {
      console.warn('Google Places sync error (fallback):', e?.message);
    }
    return null;
  }

  /**
   * Search places using PostGIS ST_DistanceSphere, optional text query, category, and criteria filters
   */
  async searchPlaces(params: SearchPlacesParams) {
    const {
      latitude,
      longitude,
      radiusMeters = 5000,
      query,
      category,
      requiredCriteria = [],
      limit = 20,
      offset = 0,
    } = params;

    let targetLat: number | undefined;
    let targetLng: number | undefined;

    // Database-First: only call Google Places sync if local DB lacks places and quota allows
    if (offset === 0 && requiredCriteria.length === 0 && config.GOOGLE_PLACES_API_KEY) {
      let shouldSync = false;

      if (query && query.trim().length > 0) {
        // If user searched for a query, check if local database already has matches
        const localMatchCount = await prisma.place.count({
          where: {
            OR: [
              { name: { contains: query.trim(), mode: 'insensitive' } },
              { address: { contains: query.trim(), mode: 'insensitive' } },
              { city: { contains: query.trim(), mode: 'insensitive' } },
            ],
          },
        });
        // If fewer than 2 matches and quota is available, sync
        if (localMatchCount < 2 && googleQuotaService.canMakeRequest()) {
          shouldSync = true;
        }
      } else if (googleQuotaService.isAutoSyncEnabled) {
        // Passive sync of coordinates: only if enabled in config and area not recently synced
        if (!googleQuotaService.isAreaSyncedRecently(latitude, longitude) && googleQuotaService.canMakeRequest()) {
          const nearbyCount = await prisma.$queryRaw<[{ count: bigint }]>`
            SELECT count(*)::bigint FROM places p
            WHERE ST_DistanceSphere(ST_MakePoint(p.longitude, p.latitude), ST_MakePoint(${longitude}, ${latitude})) <= ${radiusMeters}
          `;
          const count = Number(nearbyCount[0]?.count ?? 0);
          if (count < 3) {
            shouldSync = true;
          }
        }
      }

      if (shouldSync) {
        const syncResult = await this.syncGooglePlacesNearby(latitude, longitude, radiusMeters, query, category);
        if (syncResult) {
          targetLat = syncResult.targetLat;
          targetLng = syncResult.targetLng;
        }
      }
    }

    const whereConditions: Prisma.Sql[] = [];

    if (category) {
      whereConditions.push(Prisma.sql`p.category = ${category}`);
    }

    let centerLat = latitude;
    let centerLng = longitude;

    if (query && query.trim().length > 0) {
      const trimmedQuery = query.trim();
      if (targetLat !== undefined && targetLng !== undefined) {
        centerLat = targetLat;
        centerLng = targetLng;
        whereConditions.push(Prisma.sql`
          (
            p.name ILIKE ${`%${trimmedQuery}%`} OR 
            p.address ILIKE ${`%${trimmedQuery}%`} OR 
            p.city ILIKE ${`%${trimmedQuery}%`} OR
            ST_DistanceSphere(ST_MakePoint(p.longitude, p.latitude), ST_MakePoint(${centerLng}, ${centerLat})) <= 5000
          )
        `);
      } else {
        whereConditions.push(Prisma.sql`
          (p.name ILIKE ${`%${trimmedQuery}%`} OR p.address ILIKE ${`%${trimmedQuery}%`} OR p.city ILIKE ${`%${trimmedQuery}%`})
        `);
      }
    } else {
      whereConditions.push(
        Prisma.sql`ST_DistanceSphere(ST_MakePoint(p.longitude, p.latitude), ST_MakePoint(${centerLng}, ${centerLat})) <= ${radiusMeters}`
      );
    }

    const whereClause = Prisma.sql`WHERE ${Prisma.join(whereConditions, ' AND ')}`;

    const rawPlaces = await prisma.$queryRaw<any[]>(Prisma.sql`
      SELECT 
        p.*,
        ROUND(ST_DistanceSphere(ST_MakePoint(p.longitude, p.latitude), ST_MakePoint(${centerLng}, ${centerLat}))::numeric) AS distance_meters
      FROM places p
      ${whereClause}
      ORDER BY 
        (CASE WHEN p.total_reviews > 0 THEN 1 ELSE 0 END) DESC,
        p.overall_score DESC,
        p.total_reviews DESC,
        distance_meters ASC
    `);

    // Filter by requiredCriteria (average score >= 4.0 for specified criteria)
    let filteredPlaces = rawPlaces;
    if (requiredCriteria.length > 0) {
      const placesWithCriteria = await Promise.all(
        rawPlaces.map(async (place) => {
          const criteriaAverages = await this.getPlaceCriteriaAverages(place.id);
          const meetsCriteria = requiredCriteria.every((criterionCode) => {
            const match = criteriaAverages.find((c) => c.code === criterionCode);
            return match && match.averageScore >= 4.0;
          });
          return meetsCriteria ? place : null;
        })
      );
      filteredPlaces = placesWithCriteria.filter((p): p is any => p !== null);
    }

    const total = filteredPlaces.length;
    const paginated = filteredPlaces.slice(offset, offset + limit);

    const items = await Promise.all(
      paginated.map(async (place) => {
        const criteria = await this.getPlaceCriteriaAverages(place.id);
        return {
          id: place.id,
          name: place.name,
          category: place.category,
          address: place.address,
          city: place.city,
          state: place.state,
          latitude: Number(place.latitude),
          longitude: Number(place.longitude),
          overallScore: Number(place.overall_score),
          totalReviews: Number(place.total_reviews),
          lastReviewedAt: place.last_reviewed_at,
          distanceMeters: Math.round(Number(place.distance_meters)),
          criteriaBreakdown: criteria,
        };
      })
    );

    return { total, items };
  }

  /**
   * Get single place with detailed accessibility breakdown, photos, and reviews
   */
  async getPlaceById(placeId: string) {
    const place = await prisma.place.findUnique({
      where: { id: placeId },
      include: {
        media: {
          where: { status: 'ACTIVE' },
          take: 10,
        },
      },
    });

    if (!place) {
      throw new NotFoundError('Local não encontrado');
    }

    const criteriaBreakdown = await this.getPlaceCriteriaAverages(placeId);

    // Calculate if review is outdated (> 12 months)
    let isOutdated = false;
    if (place.last_reviewed_at) {
      const twelveMonthsAgo = new Date();
      twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 12);
      isOutdated = place.last_reviewed_at < twelveMonthsAgo;
    }

    return {
      id: place.id,
      googlePlaceId: place.google_place_id,
      source: place.source,
      name: place.name,
      description: place.description,
      category: place.category,
      address: place.address,
      city: place.city,
      state: place.state,
      postalCode: place.postal_code,
      latitude: place.latitude,
      longitude: place.longitude,
      overallScore: Number(place.overall_score),
      totalReviews: place.total_reviews,
      lastReviewedAt: place.last_reviewed_at,
      isOutdated,
      criteriaBreakdown,
      media: place.media.map((m) => ({
        id: m.id,
        mediaUrl: m.media_url,
        thumbnailUrl: m.thumbnail_url,
        altText: m.alt_text,
      })),
    };
  }

  /**
   * Create crowdsourced place
   */
  async createPlace(data: CreatePlaceDTO) {
    if (!data.name || !data.category || !data.address || !data.city || !data.state) {
      throw new BadRequestError('Campos obrigatórios de local não preenchidos');
    }

    if (data.googlePlaceId) {
      const existing = await prisma.place.findUnique({
        where: { google_place_id: data.googlePlaceId },
      });
      if (existing) {
        return this.getPlaceById(existing.id);
      }
    }

    const place = await prisma.place.create({
      data: {
        name: data.name,
        description: data.description ?? null,
        category: data.category,
        address: data.address,
        city: data.city,
        state: data.state,
        postal_code: data.postalCode ?? null,
        latitude: data.latitude,
        longitude: data.longitude,
        google_place_id: data.googlePlaceId ?? null,
        source: data.googlePlaceId ? 'GOOGLE_PLACES' : 'COMMUNITY',
      },
    });

    return this.getPlaceById(place.id);
  }

  /**
   * External search using Google Places with 24h caching and daily quota guards
   */
  async searchExternalPlaces(query?: string, latitude?: number, longitude?: number) {
    if (!query && (latitude === undefined || longitude === undefined)) {
      throw new BadRequestError('Query ou coordenadas obrigatórias para busca externa');
    }

    const cleanQuery = query?.trim() || '';

    // 1. Check 24-hour cache first (0 API requests consumed)
    const cached = googleQuotaService.getCachedSearchResults<any[]>(cleanQuery, latitude, longitude);
    if (cached) {
      return cached;
    }

    const imported = await prisma.place.findMany({
      where: {
        google_place_id: { not: null },
      },
      select: { id: true, google_place_id: true },
    });
    const importedMap = new Map(imported.map((p) => [p.google_place_id, p.id]));

    // 2. Call Google Places only if key is configured and daily quota is not exceeded
    if (config.GOOGLE_PLACES_API_KEY && googleQuotaService.canMakeRequest()) {
      try {
        let results: any[] = [];
        if (cleanQuery.length > 0) {
          googleQuotaService.recordRequest('textSearch');
          const params: any = {
            query: cleanQuery,
            key: config.GOOGLE_PLACES_API_KEY,
            language: 'pt-BR',
          };
          if (latitude !== undefined && longitude !== undefined) {
            params.location = { lat: Number(latitude), lng: Number(longitude) };
            params.radius = 5000;
          }
          const response = await this.googleMapsClient.textSearch({ params });
          results = response.data.results || [];

          // Se a busca retornou um endereço residencial/comercial ou poucos resultados,
          // busca estabelecimentos ao redor somente se ainda houver cota disponível
          if (results.length > 0) {
            const first = results[0];
            const isAddress = first.types?.some((t: string) =>
              ['street_address', 'route', 'premise', 'subpremise', 'geocode', 'postal_code', 'intersection'].includes(t)
            ) || results.length <= 4;

            if (isAddress && first.geometry?.location && googleQuotaService.canMakeRequest()) {
              try {
                googleQuotaService.recordRequest('placesNearby_address');
                const nearbyResponse = await this.googleMapsClient.placesNearby({
                  params: {
                    location: first.geometry.location,
                    radius: 1500,
                    key: config.GOOGLE_PLACES_API_KEY,
                    language: 'pt-BR' as any,
                  },
                });

                const nearbyPlaces = (nearbyResponse.data.results || []).filter((p: any) =>
                  p.place_id !== first.place_id &&
                  !p.types?.includes('locality') &&
                  !p.types?.includes('administrative_area_level_1') &&
                  !p.types?.includes('administrative_area_level_2')
                );

                results = [first, ...nearbyPlaces];
              } catch (nearbyErr: any) {
                console.warn('Could not fetch nearby places around address:', nearbyErr?.message);
              }
            }
          }
        } else if (latitude !== undefined && longitude !== undefined) {
          googleQuotaService.recordRequest('placesNearby');
          const response = await this.googleMapsClient.placesNearby({
            params: {
              location: { lat: Number(latitude), lng: Number(longitude) },
              radius: 5000,
              key: config.GOOGLE_PLACES_API_KEY,
              language: 'pt-BR' as any,
            },
          });
          results = response.data.results || [];
        }

        if (results && results.length > 0) {
          const uniquePlaces = new Map<string, any>();
          for (const item of results) {
            if (item.place_id && !uniquePlaces.has(item.place_id)) {
              uniquePlaces.set(item.place_id, item);
            }
          }

          const formattedResults = Array.from(uniquePlaces.values()).slice(0, 20).map((item) => ({
            googlePlaceId: item.place_id,
            name: item.name,
            formattedAddress: item.formatted_address || item.vicinity || `${item.name}, São Paulo, SP`,
            latitude: item.geometry?.location?.lat ?? latitude ?? -23.55052,
            longitude: item.geometry?.location?.lng ?? longitude ?? -46.633308,
            category: this.mapGoogleCategory(item.types),
            alreadyImportedId: item.place_id ? importedMap.get(item.place_id) ?? null : null,
          }));

          // Cache results for 24h
          googleQuotaService.cacheSearchResults(cleanQuery, formattedResults, latitude, longitude);

          return formattedResults;
        }
      } catch (err: any) {
        console.warn('Google Places external search fallback:', err?.message);
      }
    }

    // 3. Quota reached, key missing or Google error -> Fallback to local DB matches
    if (cleanQuery.length > 0) {
      const localMatches = await prisma.place.findMany({
        where: {
          OR: [
            { name: { contains: cleanQuery, mode: 'insensitive' } },
            { address: { contains: cleanQuery, mode: 'insensitive' } },
            { city: { contains: cleanQuery, mode: 'insensitive' } },
          ],
        },
        take: 10,
      });

      if (localMatches.length > 0) {
        return localMatches.map((p) => ({
          googlePlaceId: p.google_place_id || `local_${p.id}`,
          name: p.name,
          formattedAddress: p.address,
          latitude: Number(p.latitude),
          longitude: Number(p.longitude),
          category: p.category,
          alreadyImportedId: p.id,
        }));
      }
    }

    const fallbackQuery = cleanQuery || 'Local Próximo';
    return [
      {
        googlePlaceId: `gp_${Buffer.from(fallbackQuery).toString('hex').slice(0, 16)}`,
        name: fallbackQuery,
        formattedAddress: `${fallbackQuery}, Av. Paulista, 1000 - São Paulo, SP`,
        latitude: latitude ?? -23.5614,
        longitude: longitude ?? -46.6565,
        category: 'Restaurante',
        alreadyImportedId: importedMap.get(`gp_${Buffer.from(fallbackQuery).toString('hex').slice(0, 16)}`) ?? null,
      },
    ];
  }

  /**
   * Calculates criteria averages for a given place across all published reviews
   */
  private async getPlaceCriteriaAverages(placeId: string) {
    const criteria = await prisma.accessibilityCriterion.findMany({
      where: { is_active: true },
      orderBy: { code: 'asc' },
    });

    const ratings = await prisma.placeReviewRating.findMany({
      where: {
        review: {
          place_id: placeId,
          status: { in: ['PUBLISHED', 'UNDER_REVIEW'] },
        },
      },
      select: {
        criterion_id: true,
        score: true,
      },
    });

    const scoreMap = new Map<string, { total: number; count: number }>();
    for (const r of ratings) {
      const current = scoreMap.get(r.criterion_id) || { total: 0, count: 0 };
      current.total += r.score;
      current.count += 1;
      scoreMap.set(r.criterion_id, current);
    }

    return criteria.map((c) => {
      const stat = scoreMap.get(c.id);
      return {
        id: c.id,
        code: c.code,
        title: c.title,
        iconName: c.icon_name,
        averageScore: stat && stat.count > 0 ? Number((stat.total / stat.count).toFixed(2)) : 0,
        ratingsCount: stat ? stat.count : 0,
      };
    });
  }
}

export const placesService = new PlacesService();
