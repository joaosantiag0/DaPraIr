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

  console.log('✅ Accessibility criteria, places, reviews and events seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
