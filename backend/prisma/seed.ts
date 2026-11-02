import { PrismaClient } from '@prisma/client';

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

  console.log('✅ Accessibility criteria seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
