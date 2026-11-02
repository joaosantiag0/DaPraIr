FROM node:20-bookworm-slim AS builder

WORKDIR /app

# Install build essentials and openssl for Prisma and native bindings
RUN apt-get update && apt-get install -y openssl python3 make g++ && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install

COPY tsconfig.json ./
COPY src ./src/

RUN npx prisma generate
RUN npm run build

# Runner stage
FROM node:20-bookworm-slim AS runner

WORKDIR /app

RUN apt-get update && apt-get install -y openssl curl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install --omit=dev && npm install tsx

COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/dist ./dist
COPY docker-entrypoint.sh ./

RUN chmod +x docker-entrypoint.sh

EXPOSE 3333

ENV NODE_ENV=production \
    PORT=3333 \
    HOST=0.0.0.0

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["node", "dist/server.js"]
