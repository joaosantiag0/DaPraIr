# Quickstart: Sistema de Gamificação (Pontuação e Ranking)

**Feature**: `003-gamificacao-pontos-ranking`  
**Date**: 2026-11-05

---

## 1. Ambiente Local com Docker

Suba os serviços locais (PostgreSQL e dependências de backend):

```bash
docker compose up -d
```

---

## 2. Execução de Migrações e Seeds (Backend)

No diretório `backend`:

```bash
cd backend

# Instalar dependências (se necessário)
npm install

# Aplicar as migrações do Prisma ORM (incluindo as tabelas de gamificação)
npx prisma migrate dev --name add_gamification_tables

# Executar a seed com os níveis e insígnias padrão
npx prisma db seed
```

---

## 3. Rodar Testes Automatizados (Backend)

Validar regras de negócio, cálculo de pontuação, prevenção de duplicidade e endpoints:

```bash
cd backend

# Executar suíte de testes unitários e de integração
npm run test

# Verificar cobertura de código (mínimo de 80% exigido pela Constituição)
npm run test:coverage
```

---

## 4. Rodar Testes de Acessibilidade e Widgets (Frontend Flutter)

No diretório `frontend`:

```bash
cd frontend

# Obter dependências do Flutter
flutter pub get

# Executar testes unitários e testes de acessibilidade semântica
flutter test
```

---

## 5. Endpoints Principais para Teste Manual via cURL / Swagger

- Documentação Swagger interativa: `http://localhost:3000/docs`
- Consultar Leaderboard mensal (público):
  ```bash
  curl -X GET "http://localhost:3000/api/v1/gamification/leaderboard?period=monthly"
  ```
- Consultar saldo e perfil do usuário logado:
  ```bash
  curl -X GET "http://localhost:3000/api/v1/gamification/profile" \
       -H "Authorization: Bearer <SEU_JWT_TOKEN>"
  ```
- Atualizar privacidade de ranking (opt-out / anônimo):
  ```bash
  curl -X PUT "http://localhost:3000/api/v1/gamification/preferences" \
       -H "Authorization: Bearer <SEU_JWT_TOKEN>" \
       -H "Content-Type: application/json" \
       -d '{"is_ranking_visible": false}'
  ```
