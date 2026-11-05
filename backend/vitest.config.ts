import 'dotenv/config';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    fileParallelism: false,
    env: {
      DATABASE_URL: 'postgresql://daprair:daprair_password@localhost:5433/daprair_db?schema=public',
      NODE_ENV: 'test',
    },
    include: ['tests/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 60,
        statements: 80,
      },
      exclude: [
        'node_modules/**',
        'dist/**',
        'prisma/**',
        'tests/**',
        'vitest.config.ts',
        'src/server.ts',
      ],
    },
  },
});
