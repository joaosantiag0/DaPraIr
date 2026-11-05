import 'dotenv/config';
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient({
  datasources: {
    db: {
      url:
        process.env.DATABASE_URL ||
        'postgresql://daprair:daprair_password@localhost:5433/daprair_db?schema=public',
    },
  },
});
