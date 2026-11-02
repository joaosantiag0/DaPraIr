import { prisma } from '../../core/database/prisma.js';
import { Prisma } from '@prisma/client';
import { NotFoundError, BadRequestError } from '../../core/errors/app-error.js';

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
  description?: string;
  category: string;
  address: string;
  city: string;
  state: string;
  postalCode?: string;
  latitude: number;
  longitude: number;
  googlePlaceId?: string;
}

export class PlacesService {
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

    const whereConditions: Prisma.Sql[] = [
      Prisma.sql`ST_DistanceSphere(ST_MakePoint(p.longitude, p.latitude), ST_MakePoint(${longitude}, ${latitude})) <= ${radiusMeters}`,
    ];

    if (category) {
      whereConditions.push(Prisma.sql`p.category = ${category}`);
    }

    if (query) {
      whereConditions.push(Prisma.sql`(p.name ILIKE ${`%${query}%`} OR p.address ILIKE ${`%${query}%`})`);
    }

    const whereClause = Prisma.sql`WHERE ${Prisma.join(whereConditions, ' AND ')}`;

    const rawPlaces = await prisma.$queryRaw<any[]>(Prisma.sql`
      SELECT 
        p.*,
        ROUND(ST_DistanceSphere(ST_MakePoint(p.longitude, p.latitude), ST_MakePoint(${longitude}, ${latitude}))::numeric) AS distance_meters
      FROM places p
      ${whereClause}
      ORDER BY distance_meters ASC
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
        description: data.description,
        category: data.category,
        address: data.address,
        city: data.city,
        state: data.state,
        postal_code: data.postalCode,
        latitude: data.latitude,
        longitude: data.longitude,
        google_place_id: data.googlePlaceId,
        source: data.googlePlaceId ? 'GOOGLE_PLACES' : 'COMMUNITY',
      },
    });

    return this.getPlaceById(place.id);
  }

  /**
   * External search fallback using Google Places (or local mock for test/dev)
   */
  async searchExternalPlaces(query: string, latitude?: number, longitude?: number) {
    if (!query) {
      throw new BadRequestError('Query de busca externa obrigatória');
    }

    const imported = await prisma.place.findMany({
      where: {
        google_place_id: { not: null },
      },
      select: { id: true, google_place_id: true },
    });
    const importedMap = new Map(imported.map((p) => [p.google_place_id, p.id]));

    return [
      {
        googlePlaceId: `gp_${Buffer.from(query).toString('hex').slice(0, 16)}`,
        name: query,
        formattedAddress: `${query}, Av. Paulista, 1000 - São Paulo, SP`,
        latitude: latitude ?? -23.5614,
        longitude: longitude ?? -46.6565,
        category: 'RESTAURANT',
        alreadyImportedId: importedMap.get(`gp_${Buffer.from(query).toString('hex').slice(0, 16)}`) ?? null,
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
