# Quickstart: DáPraIr? Development & Execution Guide

**Feature Branch**: `001-acessibilidade-social-reviews`  
**Date**: 2026-11-02  
**Status**: Updated post-clarifications  

This guide provides instructions to run the **DáPraIr?** full-stack environment locally, verify accessibility, and execute automated test suites.

---

## 1. Prerequisites

- **Docker** & **Docker Compose** (v24+)
- **Node.js** 20+ & **npm** or **pnpm**
- **Flutter SDK** 3.24+ (stable channel) with Dart 3.5+
- (Optional) **Google Places API Key** (for testing external places search locally)
- (Optional) **Android Studio** / **Xcode** for mobile emulation with TalkBack / VoiceOver.

---

## 2. Infrastructure Setup (Docker + PostgreSQL + PostGIS + MinIO)

Start the local database and object storage containers:

```bash
docker compose up -d
```

This brings up:
- **PostgreSQL 16 with PostGIS** on port `5432`.
- **MinIO (Local S3 Storage)** on port `9000` (API) and `9001` (Console).

Verify that the containers are healthy:
```bash
docker compose ps
```

---

## 3. Backend Setup & Migrations

Navigate to the `backend` directory:

```bash
cd backend
npm install
```

Copy the environment template and configure secrets:
```bash
cp .env.example .env
# Set GOOGLE_PLACES_API_KEY, JWT_SECRET, and DATABASE_URL in .env
```

Run database migrations and seed initial accessibility criteria:
```bash
npx prisma migrate dev --name init
npx prisma db seed
```

Start the backend development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000/api/v1` and Swagger documentation at `http://localhost:3000/docs`.

---

## 4. Frontend Setup (Flutter Client)

In a separate terminal, navigate to the `frontend` directory:

```bash
cd frontend
flutter pub get
```

Run the application on Web or connected device:

```bash
# Para Web:
flutter run -d chrome

# Para Android (com TalkBack ativado no emulador):
flutter run -d emulator-5554

# Para iOS (com VoiceOver ativado no simulador):
flutter run -d booted
```

---

## 5. Running Automated Tests & Quality Gates

### Backend Tests (Coverage >= 80%)
```bash
cd backend
npm test -- --coverage
```

### Flutter Unit & Semantic Accessibility Tests
```bash
cd frontend
# Executa testes unitários e de widgets verificando a árvore Semantics
flutter test --coverage
```

### Quality Gate Audits
- **Acessibilidade**: Verificação da árvore semântica do Flutter (`tester.getSemantics()`) e contraste de cores.
- **LGPD**: Testes automatizados cobrindo criptografia de dados sensíveis e anonimização de conta.
- **Limiar de Moderação**: Teste de integração verificando ocultação automática após 3 denúncias distintas.
- **Barreira de Chat 1:1**: Teste verificando recusa de mensagens entre usuários sem amizade mútua aceita.
