import { prisma } from '../../core/database/prisma.js';

export interface GetFeedParams {
  userId?: string;
  latitude?: number;
  longitude?: number;
  limit?: number;
}

const DEFAULT_ACCESSIBILITY_TIPS = [
  {
    id: 'tip-1',
    title: 'Inclinação de Rampas (ABNT NBR 9050)',
    content: 'Uma rampa ideal para cadeiras de rodas deve ter inclinação entre 5% e 8,33%. Rampas acima de 10% oferecem alto risco de tombamento sem auxílio.',
    category: 'MOBILITY',
  },
  {
    id: 'tip-2',
    title: 'Portas e Vãos Livres',
    content: 'O vão livre mínimo recomendável para passagem confortável de cadeira de rodas é de 80 cm. Meça sempre com a porta aberta a 90 graus.',
    category: 'MOBILITY',
  },
  {
    id: 'tip-3',
    title: 'Sinalização Visual e Tátil',
    content: 'Piso tátil direcional orienta o trajeto contínuo, enquanto o piso tátil de alerta indica mudanças de direção, escadas e obstáculos suspensos.',
    category: 'VISION',
  },
  {
    id: 'tip-4',
    title: 'Espaços Amigáveis para Neurodivergentes',
    content: 'Locais com menor poluição sonora, iluminação indireta regulável e salas de descompressão facilitam a permanência de pessoas no espectro autista.',
    category: 'NEURODIVERSITY',
  },
];

export class FeedService {
  /**
   * Aggregate community feed (FR-021)
   */
  async getFeed(params: GetFeedParams) {
    const { userId, latitude, longitude, limit = 10 } = params;

    // 1. Highlighted / Highly rated places
    const places = await prisma.place.findMany({
      include: {
        media: {
          where: { status: 'ACTIVE' },
          take: 1,
        },
      },
      orderBy: [
        { overall_score: 'desc' },
        { total_reviews: 'desc' },
      ],
      take: 6,
    });

    const highlightedPlaces = places.map((p) => ({
      id: p.id,
      name: p.name,
      category: p.category,
      address: p.address,
      latitude: p.latitude,
      longitude: p.longitude,
      overallScore: Number(p.overall_score),
      totalReviews: p.total_reviews,
      coverImageUrl: p.media[0]?.thumbnail_url || null,
    }));

    // 2. Recent community reviews (excluding quarantined & removed)
    const recentReviewsRaw = await prisma.placeReview.findMany({
      where: {
        status: { in: ['PUBLISHED', 'UNDER_REVIEW'] },
      },
      include: {
        place: { select: { id: true, name: true, address: true } },
        user: { select: { id: true, name: true, handle: true, avatar_url: true, is_anonymous: true } },
        media: {
          where: { status: { in: ['ACTIVE', 'UNDER_REVIEW'] } },
          select: { id: true, media_url: true, thumbnail_url: true, alt_text: true },
        },
      },
      orderBy: { created_at: 'desc' },
      take: limit,
    });

    const recentReviews = recentReviewsRaw.map((r) => ({
      id: r.id,
      placeId: r.place.id,
      placeName: r.place.name,
      placeAddress: r.place.address,
      generalComment: r.general_comment,
      averageScore: Number(r.average_score),
      status: r.status,
      createdAt: r.created_at,
      author: r.user.is_anonymous
        ? { id: 'anonymous', name: 'Usuário DáPraIr?', handle: '@anonimo', avatarUrl: null }
        : {
            id: r.user.id,
            name: r.user.name,
            handle: r.user.handle.startsWith('@') ? r.user.handle : `@${r.user.handle}`,
            avatarUrl: r.user.avatar_url,
          },
      media: r.media.map((m) => ({
        id: m.id,
        mediaUrl: m.media_url,
        thumbnailUrl: m.thumbnail_url,
        altText: m.alt_text,
      })),
    }));

    // 3. Upcoming inclusive events
    const upcomingEventsRaw = await prisma.event.findMany({
      where: {
        status: 'SCHEDULED',
        start_time: { gte: new Date() },
      },
      include: {
        user: { select: { id: true, name: true, handle: true } },
        rsvps: true,
      },
      orderBy: { start_time: 'asc' },
      take: 4,
    });

    const upcomingEvents = upcomingEventsRaw.map((e) => ({
      id: e.id,
      title: e.title,
      description: e.description,
      startTime: e.start_time,
      endTime: e.end_time,
      locationName: e.location_name,
      address: e.address,
      accessibilityChecklist: e.accessibility_checklist,
      rsvpCount: e.rsvps.length,
      isAttending: userId ? e.rsvps.some((r) => r.user_id === userId && r.status === 'CONFIRMED') : false,
      organizerName: e.user.name,
    }));

    return {
      highlightedPlaces,
      recentReviews,
      upcomingEvents,
      accessibilityTips: DEFAULT_ACCESSIBILITY_TIPS,
    };
  }
}

export const feedService = new FeedService();
