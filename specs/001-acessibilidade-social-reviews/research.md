# Phase 0: Technical Research & Architecture Decisions

**Feature**: DáPraIr? - Plataforma Social e Avaliações de Acessibilidade Física  
**Branch**: `001-acessibilidade-social-reviews`  
**Date**: 2026-11-02  
**Status**: Completed (Updated post-clarifications)  

---

## 1. Backend Architecture & Runtime Stack

### Decision
- **Runtime**: Node.js 20 LTS with TypeScript 5.x.
- **Web Framework**: **Fastify** (with `@fastify/sensible`, `@fastify/jwt`, `@fastify/cors`, `@fastify/swagger`, `@fastify/websocket`).
- **ORM / Database Access**: **Prisma ORM** with PostgreSQL 16 + PostGIS extension (using raw SQL queries for spatial indexes and `ST_DWithin` radius computations).
- **Validation**: **Zod** for schema validation on all incoming DTOs, parameters, and environment variables.

### Rationale
- **Performance & Low Latency**: Fastify offers sub-millisecond route handling and built-in JSON schema validation, easily meeting the requirement of < 2.5s response time for spatial searches even on high-latency mobile networks.
- **Clean Architecture Alignment**: Fastify integrates cleanly into decoupled application layers (Controllers/Routes -> Use Cases -> Repositories -> Domain Entities). Fastify plugins isolate bounded contexts (Auth, Places, Reviews, Social, Events, Privacy).
- **PostGIS Integration**: PostgreSQL + PostGIS is the industry standard for geographic coordinates, bounding-box queries, and proximity calculations (`ST_MakePoint`, `ST_DWithin`, `ST_Distance`).

---

## 2. Frontend Architecture & Mobile / Web Stack

### Decision
- **Framework**: **Flutter 3.24+** (targeting Android, iOS, and Web).
- **State Management**: **Bloc / Cubit** (`flutter_bloc`), separating business logic from UI widgets and guaranteeing predictability and testability.
- **Local Persistence & Offline Cache**: **Drift** (SQLite reactive wrapper for Flutter) + **SharedPreferences** for user settings.
- **Networking**: **Dio** with interceptors for JWT token refresh, network retry, and offline queuing.
- **Mapping & Geolocation**: `flutter_map` (OpenStreetMap / Mapbox tiles), `geolocator` for device GPS location, and `url_launcher` for deeplinking external navigation apps.

### Rationale
- **Universal Accessibility (WCAG 2.1 AA/AAA)**: Flutter provides first-class support for `Semantics`, `SemanticsService.announce`, accessible navigation order (`FocusNode`, `FocusTraversalGroup`), and native TalkBack / VoiceOver integration.
- **Cross-Platform Parity**: A single Dart codebase targets Web, Android, and iOS with pixel-perfect consistency and unified design tokens.
- **Offline Capabilities (FR-020)**: Drift enables local SQLite caching of visited places, bookmarks, and offline draft review storage with synchronization upon reconnecting.

---

## 3. Places Discovery & Google Places API Integration (Clarification 1)

### Decision
- **Hybrid Places Architecture**:
  1. Primary search targets local PostgreSQL database (indexed with PostGIS GiST).
  2. If local results are insufficient or user explicitly searches for a venue/address, the backend queries the **Google Places API (New)** (Text Search / Nearby Search) and Google Geocoding API.
  3. When a user selects a Google Place to review or view details, the backend upserts the establishment into the local `places` table with `google_place_id`, caching its core attributes (name, formatted address, coordinates, category).
  4. If a place is neither in local DB nor in Google Places, any authenticated user can manually register it (`FR-021`) by confirming coordinates on the map or entering a street address.
- **Input Flexibility**: The application requests GPS permission via `geolocator`; if denied or if the user is planning a trip to another neighborhood/city, the UI provides an address text input with auto-complete.

### Rationale
- Avoids costly bulk pre-seeding of millions of commercial venues.
- Ensures immediate coverage across Brazil while allowing crowdsourced additions of unmapped community spaces.

---

## 4. Moderation & Automatic Content Quarantining (Clarification 2)

### Decision
- Every `place_reviews` and `place_media` record tracks `report_count` and `status` (`PUBLISHED`, `UNDER_REVIEW`, `QUARANTINED`, `REMOVED`).
- **Threshold Rule**:
  - `report_count == 0`: `PUBLISHED` (Normal display).
  - `report_count in [1, 2]`: `UNDER_REVIEW` (Remains visible, but displays a subtle accessible badge: *"Esta avaliação está sob verificação comunitária"*).
  - `report_count >= 3` (from distinct user accounts): `QUARANTINED` (Automatically hidden from all public feeds and place detail pages; escalated to the human moderation queue).

### Rationale
- Protects persons with disabilities from dangerous inaccuracies (e.g. false reports that an entrance has a ramp when it has stairs).
- Prevents malicious single-user censorship while rapidly containing harmful content through distributed consensus.

---

## 5. Guest Access & Read-Only Navigation (Clarification 3)

### Decision
- Public endpoints (`GET /places`, `GET /places/:id`, `GET /places/:id/reviews`, `GET /events`) do **not** require a JWT Bearer token (`security: []`).
- The Flutter client initializes in a "Guest Mode" if no active auth session is detected.
- Any attempt to trigger mutative actions (posting reviews, liking/favoriting, messaging in chat, creating events) renders an accessible modal dialog/bottom sheet prompting the user to sign up or log in.

### Rationale
- Zero friction for emergency accessibility lookups (e.g., finding an accessible restroom immediately while commuting).
- Increases conversion to registered accounts organically.

---

## 6. Out-of-Scope Architecture Boundaries (Clarification 4)

### Decision
- **Navigation Delegation**: Instead of embedding a heavy routing engine, the Flutter client uses `url_launcher` with standardized geo URIs:
  - Android: `geo:lat,lng?q=lat,lng(Label)` (opens Google Maps / Waze).
  - iOS: `maps://?q=Label&ll=lat,lng` (opens Apple Maps / Google Maps).
  - Web: `https://www.google.com/maps/search/?api=1&query=lat,lng`.
- **Chat Scope**: Restricted to textual messages and media thumbnails; no voice/video calls or real-time WebRTC streams.
- **No Financial Layer**: No payment gateways or booking integrations in MVP.

### Rationale
- Keeps the MVP tightly focused on its core mission (accessibility data & peer community) without unnecessary development overhead.

---

## 7. 1:1 Chat Security & Peer Isolation (Clarification 5)

### Decision
- **Strict Friendship Authorization**: An API gate check verifies that a valid `social_connections` record exists with `status == 'ACCEPTED'` between sender and recipient before saving or delivering any direct message.
- Attempts by non-friends to dispatch messages return HTTP 403 Forbidden (`CHAT_MUTUAL_FRIENDSHIP_REQUIRED`).
- Immediate block and report triggers immediately revoke active WebSocket connections between the two users.

### Rationale
- Eliminates spam, unsolicited solicitation, and harassment against vulnerable community members.

---

## 8. Privacy by Design & LGPD Sensitive Data (PR-001 ~ PR-004)

### Decision
- **Sensitive Data Classification**: Specific disability categories and assistance needs are classified as Sensitive Personal Data (Art. 5º, II da LGPD).
- **Separation of Profiles**: `users` holds only account data; `user_accessibility_profiles` holds sensitive data with `visibility` (`PUBLIC`, `FRIENDS_ONLY`, `PRIVATE`) and encrypted payload.
- **Explicit Consent Ledger**: Tracked in `user_consents` (timestamp, version, hashed IP).
- **Right to Erasure**: Dedicated `/users/me/anonymize` endpoint scrubs PII and re-attributes public reviews to an "Usuário Anônimo" without destroying community accessibility ratings.
- **Log Hygiene**: Fastify Pino logger configured with strict redaction of headers, passwords, and sensitive disability fields.

---

## 9. Testing & Quality Gates (Core Principle III & Quality Gates)

### Decision
- **Backend Testing**: Vitest + Supertest with Docker test DB; minimum 80% coverage enforced in CI.
- **Flutter Testing**: `flutter_test`, `bloc_test`, and `tester.getSemantics()` for automated accessibility tree validation.
