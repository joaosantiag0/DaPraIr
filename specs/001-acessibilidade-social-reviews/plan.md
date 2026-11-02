# Implementation Plan: DáPraIr? - Plataforma Social e Avaliações de Acessibilidade Física

**Branch**: `001-acessibilidade-social-reviews` | **Date**: 2026-11-02 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-acessibilidade-social-reviews/spec.md`  

## Summary

O **DáPraIr?** é uma plataforma comunitária e rede social voltada para pessoas com deficiência física e mobilidade reduzida, permitindo:
1. **Descoberta Híbrida de Locais**: Busca espacial no mapa por proximidade (GPS) ou endereço digitado, integrando catálogo próprio e a API do Google Places, com cadastro comunitário imediato para estabelecimentos não mapeados e delegação de rotas para apps de mapa externos via deeplink.
2. **Modo Convidado (Visitante)**: Consulta pública e irrestrita a locais, notas de acessibilidade e avaliações com fotos sem obrigatoriedade de login prévio, assegurando suporte a necessidades emergenciais de deslocamento urbano.
3. **Avaliações Multicritério Auditadas**: Avaliação de 7 critérios essenciais de acessibilidade física com notas quantitativas (1-5), fotos com audiodescrição mandatória (`alt_text`) e moderação orientada a limiar comunitário (alerta preventivo de "Sob análise" com 1-2 denúncias; auto-quarentena e ocultação ao atingir 3 denúncias distintas).
4. **Comunidade e Chat 1:1 Seguro**: Conexões entre pares baseadas em interesses comuns e preferências de acessibilidade, com canal de chat direto restrito exclusivamente a amigos aceitos para prevenir assédio e spam.
5. **Privacidade e LGPD**: Coleta mínima, consentimento explícito e granular para dados sensíveis de deficiência/saúde, controle de visibilidade (`PUBLIC`, `FRIENDS_ONLY`, `PRIVATE`), criptografia AES-256 e fluxos acessíveis de portabilidade e direito ao esquecimento/anonimização.

---

## Technical Context

**Language/Version**: TypeScript 5.4+ (Node.js 20 LTS) & Dart 3.5+ (Flutter 3.24+)  
**Primary Dependencies**:
- *Backend*: Fastify, `@fastify/jwt`, `@fastify/websocket`, `@fastify/sensible`, Prisma ORM, Zod, Argon2id, Sharp, `@googlemaps/google-maps-services-js`
- *Frontend*: Flutter SDK, `flutter_bloc`, `drift` (SQLite offline cache), `dio`, `flutter_map`, `geolocator`, `url_launcher`
**Storage**: PostgreSQL 16 com extensão PostGIS (`geography(Point, 4326)`); MinIO (Dev) / S3-compatible (Prod) para armazenamento de fotos  
**Testing**:
- *Backend*: Vitest, Supertest, c8/v8 coverage (cobertura mínima de 80% obrigatória)
- *Frontend*: `flutter_test`, `bloc_test`, testes de semântica com `tester.getSemantics()`, `integration_test`
**Target Platform**: Multiplataforma: Android (API 26+), iOS (15+), Navegadores Web modernos (Chrome, Safari, Firefox), Linux container (Docker)  
**Project Type**: Full-stack Mobile/Web application + API REST/WebSocket  
**Performance Goals**:
- Busca de locais com filtros de acessibilidade no mapa < 2.5s em redes móveis (SC-002)
- Tempo de resposta da API P95 < 200ms para consultas espaciais e listagem de avaliações
**Constraints**:
- Acessibilidade WCAG 2.1 AA obrigatória em 100% das telas e fluxos (TalkBack/VoiceOver, alvos de toque >= 48x48 dp, contraste >= 4.5:1, audiodescrição obrigatória em fotos)
- Conformidade estrita com a LGPD para dados sensíveis de deficiência e mobilidade (Art. 5º, II da Lei nº 13.709/2018)
- Suporte a cache e operação offline com rascunhos de avaliação (FR-020)
- Escopo delimitado: sem motor GPS curva-a-curva próprio, sem transações financeiras e sem chamadas de voz/vídeo no MVP
**Scale/Scope**:
- MVP inicial focado nos centros urbanos brasileiros com catálogo híbrido dinâmico
- Suporte a dezenas de milhares de usuários com arquitetura modular desacoplada e conteinerizada

---

## Constitution Check

*GATE: All gates evaluated and verified post-design.*

- [x] **Gate 1 - Acessibilidade Universal (WCAG 2.1 AA/AAA)**: Interface em Flutter com suporte integral a leitores de tela (`Semantics`), contraste mínimo de 4.5:1, tema nativo de Alto Contraste, fontes escaláveis pelo sistema operacional sem truncamento e alvos de clique >= 48x48 dp. Fotos anexadas exigem obrigatoriamente audiodescrição/alt-text (`alt_text`).
- [x] **Gate 2 - Código Limpo e Componentização**: Clean Architecture estrita (separação Apresentação/Domínio/Dados) no backend Fastify e frontend Flutter. Design System unificado de widgets reutilizáveis e acessíveis.
- [x] **Gate 3 - Testabilidade e Alta Cobertura (>= 80%)**: Cobertura mínima de 80% verificada no backend (Vitest) e frontend (`flutter_test`), incluindo asserções da árvore semântica de acessibilidade nos testes de widgets.
- [x] **Gate 4 - Privacidade e LGPD**: Minimização de dados aplicada. Dados sensíveis de deficiência são opcionais, isolados em tabela própria (`user_accessibility_profiles`), com criptografia de ponta e controle granular de visibilidade (`PUBLIC`, `FRIENDS_ONLY`, `PRIVATE`). Endpoints dedicados para exportação integral (portabilidade) e anonimização/esquecimento.
- [x] **Gate 5 - Consistência Multiplataforma e Docker**: Solução baseada em código compartilhado Flutter para Web, Android e iOS. Todo o ecossistema backend e banco de dados é provisionado via `Dockerfile` e `docker-compose.yml` com migrações versionadas via Prisma.

---

## Project Structure

### Documentation (this feature)

```text
specs/001-acessibilidade-social-reviews/
├── spec.md              # Especificação de requisitos e clarificações aprovadas
├── plan.md              # Este arquivo (plano técnico e de engenharia)
├── research.md          # Pesquisa técnica e decisões de arquitetura
├── data-model.md        # Modelo relacional, entidades e ciclo de vida
├── quickstart.md        # Guia de inicialização local e testes
├── contracts/           # Contratos de interface
│   └── openapi.yaml     # Especificação OpenAPI 3.1 da API REST/WebSocket
└── tasks.md             # Decomposição em tarefas (gerado via /speckit.tasks)
```

### Source Code (repository root)

```text
docker-compose.yml           # Orquestração do PostgreSQL 16 + PostGIS e MinIO

backend/
├── Dockerfile
├── package.json
├── tsconfig.json
├── prisma/
│   ├── schema.prisma        # Modelo relacional Prisma + PostGIS
│   ├── migrations/          # Migrações versionadas
│   └── seed.ts              # Critérios de acessibilidade padronizados
├── src/
│   ├── core/                # Clean Architecture: Erros base, criptografia LGPD, tipos
│   ├── modules/
│   │   ├── auth/            # Autenticação, tokens JWT e registros
│   │   ├── users/           # Perfis de usuário e governança de privacidade LGPD
│   │   ├── places/          # Catálogo híbrido, Google Places API e busca espacial (PostGIS)
│   │   ├── reviews/         # Avaliações multicritério, fotos e limiar de quarentena
│   │   ├── social/          # Conexões, amizades e recomendações
│   │   ├── chat/            # Mensagens diretas 1:1 restritas a amigos aceitos (WebSocket)
│   │   ├── events/          # Eventos com checklist de acessibilidade
│   │   └── reports/         # Moderação comunitária e quarentena de denúncias
│   ├── server.ts            # Inicialização Fastify, plugins e Swagger
│   └── config.ts            # Variáveis de ambiente validadas via Zod
└── tests/
    ├── unit/                # Testes unitários com Vitest
    └── integration/         # Testes de integração de endpoints e contratos

frontend/
├── pubspec.yaml
├── lib/
│   ├── core/
│   │   ├── theme/           # Design System acessível, alto contraste e tipografia
│   │   ├── network/         # Cliente Dio com interceptores de auth e offline
│   │   └── accessibility/   # Utilitários de semântica e leitor de tela
│   ├── data/
│   │   ├── models/          # DTOs e serialização JSON
│   │   ├── repositories/    # Implementação dos repositórios
│   │   └── local/           # Drift / SQLite para cache offline e rascunhos
│   ├── domain/
│   │   ├── entities/        # Modelos de domínio imutáveis
│   │   └── usecases/        # Casos de uso de negócio puros
│   └── presentation/
│       ├── bloc/            # State management com Bloc / Cubit
│       ├── components/      # Componentes acessíveis reutilizáveis (botões >= 48dp, inputs)
│       └── views/
│           ├── auth/        # Onboarding e login inclusivo
│           ├── map_search/  # Mapa, busca híbrida (GPS/endereço) e filtros em Modo Convidado
│           ├── place/       # Detalhes do local, delegação de rotas e avaliações com fotos
│           ├── profile/     # Gestão de perfil e privacidade LGPD
│           ├── social/      # Feed, amigos e chat 1:1 restrito
│           └── events/      # Criação e descoberta de eventos inclusivos
└── test/
    ├── unit/                # Testes de casos de uso e Blocs
    ├── widgets/             # Testes de componentes com validação de semântica
    └── integration_test/    # Fluxos completos E2E
```

**Structure Decision**:
Optou-se pela estrutura monorepo desacoplada `backend/` e `frontend/`. Essa separação garante clareza de responsabilidades, execução independente de pipelines de CI/CD para backend e frontend, e paridade rigorosa do ecossistema de banco de dados e microserviços através do `docker-compose.yml` na raiz do repositório.

---

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| *Nenhuma violação aos princípios constitucionais.* | A arquitetura adotada atende diretamente a todos os 5 princípios da Constituição sem complexidade acidental desnecessária. | - |
