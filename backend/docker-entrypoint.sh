#!/bin/sh
set -e

echo "⏳ Aguardando banco de dados PostgreSQL estar pronto..."
until npx prisma db push --skip-generate; do
  echo "Banco ainda não disponível, tentando novamente em 2 segundos..."
  sleep 2
done

echo "🌱 Executando seed inicial de critérios de acessibilidade..."
npx tsx prisma/seed.ts || echo "⚠️ Seed já executado ou ignorado."

echo "🚀 Iniciando servidor DáPraIr? Backend..."
exec "$@"
