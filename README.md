# DáPraIr? — Physical Accessibility Platform & Social Community

[![🇧🇷 Português](https://img.shields.io/badge/Language-Português-green?style=flat-square)](README.pt-BR.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-v3.24%2B-02569B?logo=flutter&style=flat-square)](https://flutter.dev)
[![Fastify](https://img.shields.io/badge/Fastify-v4-black?logo=fastify&style=flat-square)](https://fastify.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript&style=flat-square)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16%20%2B%20PostGIS-336791?logo=postgresql&style=flat-square)](https://www.postgresql.org)
[![WCAG](https://img.shields.io/badge/Accessibility-WCAG%202.1%20AA%2FAAA-green?style=flat-square)](https://www.w3.org/WAI/standards-guidelines/wcag/)

> **Read this in other languages:**  
> 🇺🇸 **English** | 🇧🇷 [Versão em Português](README.pt-BR.md)

**DáPraIr?** (*Can I Go There?*) is a collaborative, multi-platform (Mobile, Web, and Desktop) ecosystem designed to map, assess, and share real-world physical accessibility conditions of public venues, urban spaces, and community events.

Built in accordance with Brazilian accessibility standard **ABNT NBR 9050** and international digital accessibility guidelines **WCAG 2.1 (AA and AAA levels)**, the project unites citizen crowdsourcing, social connection, and strict data privacy compliance under **LGPD** (Brazil's General Data Protection Law).

---

## ✨ Key Features

### ♿ Citizen-Driven Accessibility Reviews
- Comprehensive location evaluations across **7 standardized criteria** based on ABNT NBR 9050.
- Photo uploads with **mandatory alternative text (`alt_text`)** for screen readers.
- Offline draft autosave via local storage (`SharedPreferences`).

### 🗺️ Smart Geospatial Search & Google Places Integration
- API quota protection with local geospatial database fallback powered by **PostGIS**.
- 24-hour query cache for cost efficiency and offline resilience.
- 500m geogrid clustering for local venue synchronization.

### 💬 Categorized Community Forums & Threaded Debates
- Public, community-restricted, and private discussions structured by topic categories.
- Nested replies and subthreads with collapsible comment trees.
- Transparent `(edited)` badges and real-time like/comment engagement counters.
- Seamless view state caching across nested screen navigation and authentication changes.

### 🤝 Social Connections & Direct Chat
- Mutual friendships, connection requests, and profile discovery based on shared accessibility needs.
- Real-time direct chat with end-to-end security and polite guest preview mode.

### 🛡️ Community Moderation & Automatic Quarantine
- Anonymous reporting on reviews, debates, and comments.
- **Automatic Quarantine**: items receiving 3+ distinct reports are instantly hidden from public feeds pending human moderation.
- Rules onboarding on the user's first post: active encouragement to report violations, and explicit guidance that political and religious extremism should be avoided and is subject to removal.

### 🔒 LGPD Compliance & Privacy by Design
- Sensitive health conditions and precise coordinates encrypted using **AES-256-GCM**.
- Passwords hashed with state-of-the-art **Argon2id**.
- Consent IP logs pseudonymized via **SHA-256**.
- Full Data Governance Panel offering **Data Portability** and the **Right to be Forgotten**.

---

## ♿ Standardized Accessibility Criteria (ABNT NBR 9050)

1. **Ramp Access or Level Entrance** (`ENTRANCE_RAMP_LEVEL`)
2. **Elevator or Lifting Platform** (`ELEVATOR_LIFT`)
3. **Accessible Bathroom** (`ADAPTED_BATHROOM`)
4. **Free Circulation & Maneuvering Space** (`MANEUVERING_SPACE`)
5. **Accessible Tables & Seating** (`ADAPTED_SEATING`)
6. **Designated Accessible Parking** (`ACCESSIBLE_PARKING`)
7. **Inclusive & Attentive Customer Service** (`INCLUSIVE_SERVICE`)

---

## 🏗️ Architecture & Tech Stack

- **Frontend**: Flutter 3.24+ (Dart 3.5+), BLoC / Cubit, Clean Architecture, Adaptive Layout (`NavigationRail` on Desktop/Tablet and `NavigationBar` on Mobile).
- **Backend**: Node.js 20+, Fastify, TypeScript, Prisma ORM, Zod.
- **Database**: PostgreSQL 16 with PostGIS geospatial extension.
- **DevOps**: Docker & Docker Compose with automated database migrations and seeding.

---

## 🚀 Getting Started

### 1. Prerequisites
- [Node.js](https://nodejs.org/) v20+ and `npm`
- [Docker & Docker Compose](https://www.docker.com/)
- [Flutter SDK](https://flutter.dev) v3.24+

---

### 2. Fast Launch with Docker (Recommended)
Spin up the PostGIS database and Fastify backend with a single command:

```bash
docker compose up -d --build
```

The container automatically waits for PostgreSQL health checks, runs `prisma db push`, and executes data seeds.

- **REST API**: `http://localhost:3333`
- **Swagger / OpenAPI Documentation**: `http://localhost:3333/docs`
- **PostgreSQL / PostGIS**: port `5433` (mapped to container port `5432`)

---

### 3. Running Backend Locally (Without Docker)
```bash
cd backend
npm install
npx prisma db push
npx tsx prisma/seed.ts
npm run dev
```

Run test suite with coverage report (target >= 80%):
```bash
npm run test:coverage
```

---

### 4. Running the Flutter Frontend
```bash
cd frontend
flutter pub get

# Launch on Web (Chrome)
flutter run -d chrome

# Launch on macOS Desktop
flutter run -d macos

# Launch on Mobile Emulator / Physical Device
flutter run
```

Run frontend widget & unit tests with WCAG accessibility validation:
```bash
flutter test --coverage
```

---

## 📜 License & Attribution

This project is licensed under the terms of the **MIT License** — see the [LICENSE](LICENSE) file for complete details.

### ⚠️ Attribution & Credit Requirement
In accordance with the MIT License terms, **you must retain the original copyright notice and give proper credit** whenever using, forking, modifying, or distributing this software or derivatives:

- **Original Author**: [João Santiago](https://github.com/joaosantiag0)
- **Repository**: [https://github.com/joaosantiag0/daPraIr](https://github.com/joaosantiag0/daPraIr)
- **Project**: DáPraIr? — Physical Accessibility Platform & Social Community
