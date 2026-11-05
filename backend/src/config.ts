import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  HOST: z.string().default('0.0.0.0'),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  JWT_SECRET: z.string().min(16, 'JWT_SECRET must have at least 16 characters'),
  ENCRYPTION_KEY: z.string().length(64, 'ENCRYPTION_KEY must be a 64-hex character string (32 bytes)'),
  S3_ENDPOINT: z.string().url().default('http://localhost:9000'),
  S3_REGION: z.string().default('us-east-1'),
  S3_ACCESS_KEY: z.string().min(1, 'S3_ACCESS_KEY is required'),
  S3_SECRET_KEY: z.string().min(1, 'S3_SECRET_KEY is required'),
  S3_BUCKET_NAME: z.string().default('daprair-media'),
  S3_FORCE_PATH_STYLE: z.coerce.boolean().default(true),
  GOOGLE_PLACES_API_KEY: z.string().optional().default(''),
  GOOGLE_PLACES_DAILY_LIMIT: z.coerce.number().default(30),
  ENABLE_AUTO_GOOGLE_PLACES_SYNC: z.coerce.boolean().default(false),
  ADMIN_EMAILS: z.string().optional().default(''),
  ADMIN_EMAIL: z.string().optional().default(''),
});

const _env = envSchema.safeParse(process.env);

if (!_env.success) {
  console.error('❌ Invalid environment configuration:', JSON.stringify(_env.error.format(), null, 2));
  throw new Error('Invalid environment variables');
}

export const config = _env.data;
export type Config = z.infer<typeof envSchema>;
