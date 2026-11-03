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
  {
    id: 'tip-5',
    title: 'Sanitários Acessíveis e Barras de Apoio',
    content: 'O banheiro adaptado deve possuir barras de apoio horizontais fixas e articuladas, raio de giro de 360° (1,50 m) e porta que abra para fora ou seja de correr com trinco ergonômico.',
    category: 'MOBILITY',
  },
  {
    id: 'tip-6',
    title: 'Vagas de Estacionamento Reservadas (Lei 13.146)',
    content: 'O Estatuto da Pessoa com Deficiência assegura 2% das vagas em estacionamentos públicos e privados, com faixa de circulação adicional de 1,20 m para desembarque de cadeira de rodas.',
    category: 'MOBILITY',
  },
];

const DEFAULT_HIGHLIGHTED_PLACES = [
  {
    id: 'place-pinacoteca',
    name: 'Pinacoteca de São Paulo',
    category: 'MUSEUM',
    address: 'Praça da Luz, 2 - Luz, São Paulo - SP',
    latitude: -23.5348,
    longitude: -46.6341,
    overallScore: 4.9,
    totalReviews: 42,
    coverImageUrl: null,
  },
  {
    id: 'place-ibirapuera',
    name: 'Parque Ibirapuera',
    category: 'PARK',
    address: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
    latitude: -23.5874,
    longitude: -46.6576,
    overallScore: 4.8,
    totalReviews: 128,
    coverImageUrl: null,
  },
  {
    id: 'place-sesc-pompeia',
    name: 'Sesc Pompeia',
    category: 'THEATER',
    address: 'Rua Clélia, 93 - Água Branca, São Paulo - SP',
    latitude: -23.5262,
    longitude: -46.6853,
    overallScore: 4.9,
    totalReviews: 56,
    coverImageUrl: null,
  },
  {
    id: 'place-museu-futebol',
    name: 'Museu do Futebol (Pacaembu)',
    category: 'MUSEUM',
    address: 'Praça Charles Miller, s/n - Pacaembu, São Paulo - SP',
    latitude: -23.5483,
    longitude: -46.6654,
    overallScore: 4.7,
    totalReviews: 38,
    coverImageUrl: null,
  },
  {
    id: 'place-terraco-italia',
    name: 'Restaurante Terraço Itália',
    category: 'RESTAURANT',
    address: 'Av. Ipiranga, 344 - 41º andar - República, São Paulo - SP',
    latitude: -23.5451,
    longitude: -46.6433,
    overallScore: 4.6,
    totalReviews: 19,
    coverImageUrl: null,
  },
  {
    id: 'place-livraria-vila',
    name: 'Livraria da Vila - Fradique',
    category: 'STORE',
    address: 'Rua Fradique Coutinho, 915 - Pinheiros, São Paulo - SP',
    latitude: -23.5602,
    longitude: -46.6891,
    overallScore: 4.5,
    totalReviews: 15,
    coverImageUrl: null,
  },
];

const DEFAULT_RECENT_REVIEWS = [
  {
    id: 'rev-pinacoteca-1',
    placeId: 'place-pinacoteca',
    placeName: 'Pinacoteca de São Paulo',
    placeAddress: 'Praça da Luz, 2 - Luz, São Paulo - SP',
    generalComment: 'Experiência impecável! Entrada pela lateral totalmente nivelada, elevadores panorâmicos espaçosos para cadeira motorizada e banheiros adaptados excelentes com alarme sonoro.',
    averageScore: 5.0,
    status: 'PUBLISHED',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 3), // 3 hours ago
    author: {
      id: 'user-juliana',
      name: 'Juliana Mendes',
      handle: '@ju_mendes',
      avatarUrl: null,
    },
    media: [
      {
        id: 'media-pina-1',
        mediaUrl: '/media/pina_rampa.jpg',
        thumbnailUrl: '/media/pina_rampa.jpg',
        altText: 'Rampa de acesso suave com piso antiderrapante e corrimão duplo na entrada lateral da Pinacoteca.',
      },
    ],
  },
  {
    id: 'rev-ibira-1',
    placeId: 'place-ibirapuera',
    placeName: 'Parque Ibirapuera',
    placeAddress: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
    generalComment: 'O parque é maravilhoso para passear. As pistas entre os portões 3 e 7 estão recapeadas e sem buracos. Os sanitários adaptados do Pavilhão das Culturas Brasileiras têm barras firmes.',
    averageScore: 4.8,
    status: 'PUBLISHED',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 8), // 8 hours ago
    author: {
      id: 'user-marcos',
      name: 'Marcos Vinícius',
      handle: '@marcos_v',
      avatarUrl: null,
    },
    media: [],
  },
  {
    id: 'rev-sesc-1',
    placeId: 'place-sesc-pompeia',
    placeName: 'Sesc Pompeia',
    placeAddress: 'Rua Clélia, 93 - Água Branca, São Paulo - SP',
    generalComment: 'Um dos melhores espaços culturais da cidade para cadeirantes. Rampas de concreto com inclinação ideal, mesas do restaurante na altura correta e equipe atenciosa.',
    averageScore: 5.0,
    status: 'PUBLISHED',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
    author: {
      id: 'user-carla',
      name: 'Carla Albuquerque',
      handle: '@carla_a',
      avatarUrl: null,
    },
    media: [],
  },
  {
    id: 'rev-futebol-1',
    placeId: 'place-museu-futebol',
    placeName: 'Museu do Futebol (Pacaembu)',
    placeAddress: 'Praça Charles Miller, s/n - Pacaembu, São Paulo - SP',
    generalComment: 'Muito bem adaptado! Elevador para todos os andares de exposição, piso tátil por todo o percurso e mesas de áudio interativas bem posicionadas para cadeirantes.',
    averageScore: 4.7,
    status: 'PUBLISHED',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 36), // 1.5 days ago
    author: {
      id: 'user-roberto',
      name: 'Roberto Fernandes',
      handle: '@roberto_f',
      avatarUrl: null,
    },
    media: [],
  },
  {
    id: 'rev-under-review-1',
    placeId: 'place-inclusao',
    placeName: 'Museu da Inclusão',
    placeAddress: 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP',
    generalComment: 'Excelente rampa e guias atenciosos! Todo o espaço foi pensado com desenho universal desde a concepção.',
    averageScore: 5.0,
    status: 'UNDER_REVIEW',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 48), // 2 days ago
    author: {
      id: 'user-carlos',
      name: 'Carlos Silva',
      handle: '@carlos_s',
      avatarUrl: null,
    },
    media: [],
  },
];

const DEFAULT_UPCOMING_EVENTS = [
  {
    id: 'event-pinacoteca-visita',
    title: 'Visita Guiada Multissensorial na Pinacoteca',
    description: 'Visita mediada com audiodescrição, maquetes táteis das obras e percurso 100% nivelado.',
    startTime: new Date(Date.now() + 1000 * 60 * 60 * 24 * 3), // 3 days ahead
    endTime: new Date(Date.now() + 1000 * 60 * 60 * 24 * 3 + 1000 * 60 * 60 * 3),
    locationName: 'Pinacoteca de São Paulo',
    address: 'Praça da Luz, 2 - Luz, São Paulo - SP',
    accessibilityChecklist: {
      rampa_acesso: true,
      elevador: true,
      banheiro_adaptado: true,
      guia_cego: true,
      interprete_libras: true,
    },
    rsvpCount: 28,
    isAttending: false,
    organizerName: 'Educativo Pinacoteca',
  },
  {
    id: 'event-ibira-piquenique',
    title: 'Passeio & Piquenique Inclusivo no Ibirapuera',
    description: 'Encontro comunitário de cadeirantes e pessoas com mobilidade reduzida para compartilhar dicas de acessibilidade urbana.',
    startTime: new Date(Date.now() + 1000 * 60 * 60 * 24 * 6), // 6 days ahead
    endTime: new Date(Date.now() + 1000 * 60 * 60 * 24 * 6 + 1000 * 60 * 60 * 4),
    locationName: 'Parque Ibirapuera (Portão 10)',
    address: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
    accessibilityChecklist: {
      rampa_acesso: true,
      banheiro_adaptado: true,
      estacionamento_reservado: true,
      espaco_manobra: true,
    },
    rsvpCount: 45,
    isAttending: false,
    organizerName: 'Marina Cordeiro',
  },
  {
    id: 'event-sarau-libras',
    title: 'Sarau com Acessibilidade e Poesia Viva',
    description: 'Música e poesia com audiodescrição ao vivo e tradução simultânea em Língua Brasileira de Sinais (Libras).',
    startTime: new Date(Date.now() + 1000 * 60 * 60 * 24 * 10), // 10 days ahead
    endTime: new Date(Date.now() + 1000 * 60 * 60 * 24 * 10 + 1000 * 60 * 60 * 3),
    locationName: 'Centro Cultural São Paulo (CCSP)',
    address: 'Rua Vergueiro, 1000 - Paraíso, São Paulo - SP',
    accessibilityChecklist: {
      rampa_acesso: true,
      elevador: true,
      banheiro_adaptado: true,
      interprete_libras: true,
    },
    rsvpCount: 34,
    isAttending: false,
    organizerName: 'Coletivo Acesso Livre',
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

    let highlightedPlaces = places.map((p) => ({
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

    if (highlightedPlaces.length === 0) {
      highlightedPlaces = DEFAULT_HIGHLIGHTED_PLACES;
    }

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

    let recentReviews = recentReviewsRaw.map((r) => ({
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

    if (recentReviews.length === 0) {
      recentReviews = DEFAULT_RECENT_REVIEWS;
    }

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

    let upcomingEvents = upcomingEventsRaw.map((e) => ({
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

    if (upcomingEvents.length === 0) {
      upcomingEvents = DEFAULT_UPCOMING_EVENTS.map((e) => ({
        ...e,
        isAttending: false,
      }));
    }

    return {
      highlightedPlaces,
      recentReviews,
      upcomingEvents,
      accessibilityTips: DEFAULT_ACCESSIBILITY_TIPS,
    };
  }
}

export const feedService = new FeedService();
