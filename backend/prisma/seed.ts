import { PrismaClient } from '@prisma/client';
import argon2 from 'argon2';

const prisma = new PrismaClient();

const STANDARD_CRITERIA = [
  {
    code: 'ENTRANCE_RAMP_LEVEL',
    title: 'Entrada com Rampa ou Nivelada',
    description: 'Acesso principal ou secundário sem degraus ou com rampa de inclinação adequada e piso antiderrapante.',
    icon_name: 'accessible_forward',
    weight: 1.0,
  },
  {
    code: 'ELEVATOR_LIFT',
    title: 'Elevador ou Plataforma Elevatória',
    description: 'Elevador acessível ou plataforma elevatória para vencer desníveis entre pavimentos.',
    icon_name: 'elevator',
    weight: 1.0,
  },
  {
    code: 'ADAPTED_BATHROOM',
    title: 'Banheiro Adaptado',
    description: 'Sanitário acessível unissex ou específico com barras de apoio, espaço para giro de 360° e portas largas.',
    icon_name: 'wc',
    weight: 1.0,
  },
  {
    code: 'MANEUVERING_SPACE',
    title: 'Espaço de Circulação e Manobra',
    description: 'Corredores largos (mínimo 90 cm), sem obstáculos e com rotas acessíveis livres.',
    icon_name: 'open_with',
    weight: 1.0,
  },
  {
    code: 'ADAPTED_SEATING',
    title: 'Assentos e Mesas Acessíveis',
    description: 'Mesas com vão livre inferior para encaixe de cadeira de rodas e assentos reservados sinalizados.',
    icon_name: 'chair',
    weight: 1.0,
  },
  {
    code: 'ACCESSIBLE_PARKING',
    title: 'Vagas de Estacionamento Reservadas',
    description: 'Vagas para pessoas com deficiência próximas ao acesso, devidamente sinalizadas e com faixa de desembarque.',
    icon_name: 'local_parking',
    weight: 1.0,
  },
  {
    code: 'INCLUSIVE_SERVICE',
    title: 'Atendimento Inclusivo e Prioritário',
    description: 'Equipe capacitada para atendimento prioritário e apoio respeitoso a pessoas com deficiência física e mobilidade reduzida.',
    icon_name: 'support_agent',
    weight: 1.0,
  },
];

async function main() {
  console.log('🌱 Seeding standardized accessibility criteria...');

  for (const criterion of STANDARD_CRITERIA) {
    await prisma.accessibilityCriterion.upsert({
      where: { code: criterion.code },
      update: criterion,
      create: criterion,
    });
  }

  const allCriteria = await prisma.accessibilityCriterion.findMany();
  const criteriaMap: Record<string, string> = {};
  for (const c of allCriteria) {
    criteriaMap[c.code] = c.id;
  }

  console.log('🌱 Seeding sample community users...');
  const passwordHash = await argon2.hash('SenhaForte123!', {
    type: argon2.argon2id,
  });

  const usersData = [
    {
      email: 'juliana.mendes@daprair.com.br',
      name: 'Juliana Mendes',
      handle: 'ju_mendes',
      password_hash: passwordHash,
      role: 'USER',
      badges: ['VERIFIED_REVIEWER', 'TOP_CONTRIBUTOR'],
    },
    {
      email: 'marcos.vinicius@daprair.com.br',
      name: 'Marcos Vinícius',
      handle: 'marcos_v',
      password_hash: passwordHash,
      role: 'USER',
      badges: ['COMMUNITY_GUIDE'],
    },
    {
      email: 'carla.albuquerque@daprair.com.br',
      name: 'Carla Albuquerque',
      handle: 'carla_a',
      password_hash: passwordHash,
      role: 'USER',
      badges: ['VERIFIED_REVIEWER'],
    },
    {
      email: 'roberto.fernandes@daprair.com.br',
      name: 'Roberto Fernandes',
      handle: 'roberto_f',
      password_hash: passwordHash,
      role: 'USER',
      badges: [],
    },
  ];

  const createdUsers: Record<string, any> = {};
  for (const u of usersData) {
    const user = await prisma.user.upsert({
      where: { email: u.email },
      update: u,
      create: u,
    });
    createdUsers[u.handle] = user;
  }

  console.log('🌱 Seeding sample accessible places...');
  const placesData = [
    {
      name: 'Pinacoteca de São Paulo',
      category: 'MUSEUM',
      address: 'Praça da Luz, 2 - Luz, São Paulo - SP',
      city: 'São Paulo',
      state: 'SP',
      postal_code: '01120-010',
      latitude: -23.5348,
      longitude: -46.6341,
      overall_score: 4.9,
      total_reviews: 42,
      last_reviewed_at: new Date(),
    },
    {
      name: 'Parque Ibirapuera',
      category: 'PARK',
      address: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
      city: 'São Paulo',
      state: 'SP',
      postal_code: '04094-050',
      latitude: -23.5874,
      longitude: -46.6576,
      overall_score: 4.8,
      total_reviews: 128,
      last_reviewed_at: new Date(),
    },
    {
      name: 'Sesc Pompeia',
      category: 'THEATER',
      address: 'Rua Clélia, 93 - Água Branca, São Paulo - SP',
      city: 'São Paulo',
      state: 'SP',
      postal_code: '05042-000',
      latitude: -23.5262,
      longitude: -46.6853,
      overall_score: 4.9,
      total_reviews: 56,
      last_reviewed_at: new Date(),
    },
    {
      name: 'Museu do Futebol (Pacaembu)',
      category: 'MUSEUM',
      address: 'Praça Charles Miller, s/n - Pacaembu, São Paulo - SP',
      city: 'São Paulo',
      state: 'SP',
      postal_code: '01234-010',
      latitude: -23.5483,
      longitude: -46.6654,
      overall_score: 4.7,
      total_reviews: 38,
      last_reviewed_at: new Date(),
    },
    {
      name: 'Restaurante Terraço Itália',
      category: 'RESTAURANT',
      address: 'Av. Ipiranga, 344 - 41º andar - Centro Histórico, São Paulo - SP',
      city: 'São Paulo',
      state: 'SP',
      postal_code: '01046-010',
      latitude: -23.5451,
      longitude: -46.6433,
      overall_score: 4.6,
      total_reviews: 19,
      last_reviewed_at: new Date(),
    },
    {
      name: 'Livraria da Vila - Fradique',
      category: 'STORE',
      address: 'Rua Fradique Coutinho, 915 - Pinheiros, São Paulo - SP',
      city: 'São Paulo',
      state: 'SP',
      postal_code: '05416-011',
      latitude: -23.5602,
      longitude: -46.6891,
      overall_score: 4.5,
      total_reviews: 15,
      last_reviewed_at: new Date(),
    },
  ];

  for (const p of placesData) {
    const existing = await prisma.place.findFirst({
      where: { name: p.name },
    });

    let placeId = existing?.id;
    if (!existing) {
      const created = await prisma.place.create({ data: p });
      placeId = created.id;
    }

    if (placeId) {
      const reviewCount = await prisma.placeReview.count({ where: { place_id: placeId } });
      if (reviewCount === 0) {
        const juliana = createdUsers['ju_mendes'];
        if (juliana) {
          const review = await prisma.placeReview.create({
            data: {
              place_id: placeId,
              user_id: juliana.id,
              general_comment: `Excelente acessibilidade no local ${p.name}! Espaço amplo, rampa bem sinalizada e banheiros adaptados em perfeito funcionamento.`,
              average_score: 5.0,
              status: 'PUBLISHED',
            },
          });

          for (const crit of STANDARD_CRITERIA) {
            const criterionId = criteriaMap[crit.code];
            if (criterionId) {
              await prisma.placeReviewRating.create({
                data: {
                  review_id: review.id,
                  criterion_id: criterionId,
                  score: 5,
                },
              });
            }
          }
        }
      }
    }
  }

  console.log('🌱 Seeding sample inclusive events...');
  const eventsData = [
    {
      title: 'Visita Guiada Multissensorial na Pinacoteca',
      description: 'Visita mediada com audiodescrição, maquetes táteis das obras e percurso 100% nivelado.',
      location_name: 'Pinacoteca de São Paulo',
      address: 'Praça da Luz, 2 - Luz, São Paulo - SP',
      start_time: new Date(Date.now() + 1000 * 60 * 60 * 24 * 3),
      end_time: new Date(Date.now() + 1000 * 60 * 60 * 24 * 3 + 1000 * 60 * 60 * 3),
      accessibility_checklist: {
        rampa_acesso: true,
        elevador: true,
        banheiro_adaptado: true,
        guia_cego: true,
        interprete_libras: true,
      },
    },
    {
      title: 'Passeio & Piquenique Inclusivo no Ibirapuera',
      description: 'Encontro comunitário de cadeirantes e pessoas com mobilidade reduzida para compartilhar dicas de acessibilidade urbana.',
      location_name: 'Parque Ibirapuera (Portão 10)',
      address: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
      start_time: new Date(Date.now() + 1000 * 60 * 60 * 24 * 6),
      end_time: new Date(Date.now() + 1000 * 60 * 60 * 24 * 6 + 1000 * 60 * 60 * 4),
      accessibility_checklist: {
        rampa_acesso: true,
        banheiro_adaptado: true,
        estacionamento_reservado: true,
        espaco_manobra: true,
      },
    },
  ];

  const adminUser = createdUsers['ju_mendes'];
  if (adminUser) {
    for (const ev of eventsData) {
      const existing = await prisma.event.findFirst({
        where: { title: ev.title },
      });
      if (!existing) {
        await prisma.event.create({
          data: {
            ...ev,
            creator_id: adminUser.id,
            status: 'SCHEDULED',
          },
        });
      }
    }
  }

  console.log('🌱 Seeding forum categories and sample public discussions...');
  const forumCategoriesData = [
    {
      name: 'Conversa Livre & Comunidade',
      slug: 'conversa-livre',
      description: 'Espaço aberto para conversar sobre qualquer assunto do dia a dia, trocar ideias e fazer amigos, sempre respeitando as regras da comunidade.',
      icon_name: 'forum',
      display_order: 0,
      is_active: true,
    },
    {
      name: 'Mobilidade Urbana',
      slug: 'mobilidade-urbana',
      description: 'Debates sobre calçadas, transporte público, ônibus, metrô e rotas acessíveis nas cidades.',
      icon_name: 'directions_bus',
      display_order: 1,
      is_active: true,
    },
    {
      name: 'Bares e Restaurantes',
      slug: 'bares-e-restaurantes',
      description: 'Dicas, experiências e avaliações sobre gastronomia acessível e banheiros adaptados.',
      icon_name: 'restaurant',
      display_order: 2,
      is_active: true,
    },
    {
      name: 'Cultura e Lazer',
      slug: 'cultura-e-lazer',
      description: 'Parques, cinemas, teatros, museus e espaços ao ar livre com rotas inclusivas.',
      icon_name: 'theater_comedy',
      display_order: 3,
      is_active: true,
    },
    {
      name: 'Tecnologia Assistiva',
      slug: 'tecnologia-assistiva',
      description: 'Cadeiras motorizadas, adaptações veiculares, rampas portáteis e inovações.',
      icon_name: 'devices',
      display_order: 4,
      is_active: true,
    },
    {
      name: 'Legislação e Direitos PcD',
      slug: 'legislacao-e-direitos-pcd',
      description: 'Normas ABNT NBR 9050, Lei Brasileira de Inclusão (LBI) e garantia de direitos.',
      icon_name: 'gavel',
      display_order: 5,
      is_active: true,
    },
  ];

  for (const cat of forumCategoriesData) {
    await prisma.forumCategory.upsert({
      where: { slug: cat.slug },
      update: cat,
      create: cat,
    });
  }

  const mobCategory = await prisma.forumCategory.findUnique({
    where: { slug: 'mobilidade-urbana' },
  });

  const juUser = createdUsers['ju_mendes'];
  const marcosUser = createdUsers['marcos_v'];

  if (mobCategory && juUser && marcosUser) {
    let topic = await prisma.forumTopic.findFirst({
      where: { title: 'Rampas de acesso em novas linhas de ônibus elétricos' },
    });

    if (!topic) {
      topic = await prisma.forumTopic.create({
        data: {
          category_id: mobCategory.id,
          author_id: juUser.id,
          title: 'Rampas de acesso em novas linhas de ônibus elétricos',
          content: 'Notaram que a inclinação das rampas nos novos modelos elétricos da zona sul ficou muito melhor? Gostaria de saber as experiências de outros cadeirantes na linha 6000.',
          visibility: 'PUBLIC',
          status: 'ACTIVE',
          likes_count: 2,
          comments_count: 2,
        },
      });

      // Seed likes
      await prisma.forumTopicLike.createMany({
        data: [
          { topic_id: topic.id, user_id: juUser.id },
          { topic_id: topic.id, user_id: marcosUser.id },
        ],
        skipDuplicates: true,
      });

      // Level 1 Comment
      const comment1 = await prisma.forumComment.create({
        data: {
          topic_id: topic.id,
          author_id: marcosUser.id,
          content: 'Testei ontem no ponto da Av. Santo Amaro! O motorista acionou o rebaixamento pneumático com facilidade.',
          depth: 1,
          visibility: 'PUBLIC',
          status: 'ACTIVE',
          likes_count: 1,
        },
      });

      // Level 2 Subthread reply
      await prisma.forumComment.create({
        data: {
          topic_id: topic.id,
          parent_id: comment1.id,
          author_id: juUser.id,
          reply_to_user_id: marcosUser.id,
          content: 'Que alívio ouvir isso! O rebaixamento faz toda a diferença para cadeiras manuais.',
          depth: 2,
          visibility: 'PUBLIC',
          status: 'ACTIVE',
          likes_count: 0,
        },
      });

      // Update topic count in category
      await prisma.forumCategory.update({
        where: { id: mobCategory.id },
        data: { topics_count: 1 },
      });
    }
  }

  console.log('🌱 Seeding gamification levels and sample user profiles...');
  const GAMIFICATION_LEVELS = [
    {
      id: 'EXPLORER',
      name: 'Explorador(a) Iniciante',
      min_points: 0,
      level_order: 1,
      badge_icon_url: '/badges/explorer.png',
      description: 'Primeiros passos na comunidade DáPraIr? descobrindo locais e dicas.',
    },
    {
      id: 'COLLABORATOR',
      name: 'Colaborador(a) Ativo',
      min_points: 100,
      level_order: 2,
      badge_icon_url: '/badges/collaborator.png',
      description: 'Contribui regularmente com avaliações e dicas de acessibilidade física.',
    },
    {
      id: 'MAPPER',
      name: 'Mapeador(a) de Acessibilidade',
      min_points: 300,
      level_order: 3,
      badge_icon_url: '/badges/mapper.png',
      description: 'Referência em mapear e registrar fotos comprobatórias de rampas e banheiros.',
    },
    {
      id: 'SPECIALIST',
      name: 'Especialista Comunitário',
      min_points: 700,
      level_order: 4,
      badge_icon_url: '/badges/specialist.png',
      description: 'Alto engajamento, apoio a outros membros e debates resolutivos.',
    },
    {
      id: 'AMBASSADOR',
      name: 'Embaixador(a) da Acessibilidade',
      min_points: 1500,
      level_order: 5,
      badge_icon_url: '/badges/ambassador.png',
      description: 'Pilar da comunidade DáPraIr? e guardião da acessibilidade urbana inclusiva.',
    },
  ];

  for (const level of GAMIFICATION_LEVELS) {
    await prisma.gamificationLevel.upsert({
      where: { id: level.id },
      update: level,
      create: level,
    });
  }

  // Seed initial profiles for sample users
  if (juUser) {
    await prisma.userGamificationProfile.upsert({
      where: { user_id: juUser.id },
      update: {},
      create: {
        user_id: juUser.id,
        points_total: 420,
        points_current: 420,
        current_level_id: 'MAPPER',
        is_ranking_visible: true,
        use_anonymous_nickname: false,
      },
    });

    await prisma.gamificationTransaction.upsert({
      where: {
        user_id_action_type_source_id: {
          user_id: juUser.id,
          action_type: 'AVALIACAO_LOCAL',
          source_id: '00000000-0000-0000-0000-000000000001',
        },
      },
      update: {},
      create: {
        user_id: juUser.id,
        action_type: 'AVALIACAO_LOCAL',
        points: 35,
        source_id: '00000000-0000-0000-0000-000000000001',
        source_type: 'REVIEW',
        description: 'Avaliação detalhada com fotos de acessibilidade',
      },
    });
  }

  if (marcosUser) {
    await prisma.userGamificationProfile.upsert({
      where: { user_id: marcosUser.id },
      update: {},
      create: {
        user_id: marcosUser.id,
        points_total: 180,
        points_current: 180,
        current_level_id: 'COLLABORATOR',
        is_ranking_visible: true,
        use_anonymous_nickname: false,
      },
    });
  }

  console.log('✅ Accessibility criteria, places, reviews, events, forum and gamification seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
