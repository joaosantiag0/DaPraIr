---

description: "Task list for feature implementation: Espaço de Debate e Fórum de Tópicos Categorizados"
---

# Tasks: Espaço de Debate e Fórum de Tópicos Categorizados

**Input**: Design documents from `/specs/002-forum-topics-discussions/`  
**Prerequisites**: [plan.md](./plan.md) (required), [spec.md](./spec.md) (required), [data-model.md](./data-model.md), [contracts/openapi.yaml](./contracts/openapi.yaml), [research.md](./research.md), [quickstart.md](./quickstart.md)  

**Tests**: Tests are MANDATORY per Constitution (Principle III: Testabilidade Contínua e Alta Cobertura >= 80%). Every story includes unit tests, widget/accessibility tests (WCAG 2.1 AA), and integration/contract tests.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Full-stack Monorepo**: `backend/src/`, `backend/tests/`, `frontend/lib/`, `frontend/test/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, database schemas, and shared infrastructure

- [X] T001 Create directory structure for forum backend in `backend/src/modules/forum/` and frontend in `frontend/lib/presentation/views/forum/`, `frontend/lib/presentation/bloc/forum/`, and `frontend/lib/presentation/components/`
- [X] T002 Update Prisma schema in `backend/prisma/schema.prisma` with `ForumCategory`, `ForumTopic`, `ForumComment`, `ForumTopicLike`, `ForumCommentLike` models, relational indexes, and user inverse relations
- [X] T003 [P] Generate Prisma Client and create versioned SQL migration in `backend/prisma/migrations/`
- [X] T004 [P] Update database seed script in `backend/prisma/seed.ts` with curated initial categories and sample public discussions

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core validation schemas, domain contracts, and shared components that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Implement Zod validation schemas for forum categories, topics, comments, and query filters in `backend/src/modules/forum/forum.schemas.ts`
- [X] T006 Create base domain entities in `frontend/lib/domain/entities/forum_category.dart`, `frontend/lib/domain/entities/forum_topic.dart`, and `frontend/lib/domain/entities/forum_comment.dart`
- [X] T007 [P] Define abstract forum repository contract in `frontend/lib/domain/repositories/forum_repository.dart`
- [X] T008 [P] Implement reusable `VisibilityBadge` component with WCAG 2.1 AA high contrast (>= 4.5:1) in `frontend/lib/presentation/components/visibility_badge.dart`
- [X] T009 Register forum module route plugin in Fastify server in `backend/src/server.ts`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Criação e Navegação de Tópicos em Categorias Temáticas (Priority: P1) 🎯 MVP

**Goal**: Permitir que usuários autenticados naveguem por categorias temáticas, filtrem tópicos, curtam discussões e abram novos tópicos definindo visibilidade (`PUBLIC`, `COMMUNITY`, `AUTHOR`).

**Independent Test**: Autenticar usuário, acessar catálogo de categorias, abrir novo tópico com título, categoria e visibilidade, verificar se aparece na listagem correta com filtros e contador de curtidas funcional.

### Tests for User Story 1 (MANDATORY - >= 80% coverage + Accessibility) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T010 [P] [US1] Unit tests for topic visibility rules, category management, sorting filters, and topic likes in `backend/tests/unit/forum.service.test.ts`
- [X] T011 [P] [US1] Integration tests for categories and topics endpoints (`/api/v1/forum/categories`, `/api/v1/forum/topics`, `/api/v1/forum/topics/:id/like`) in `backend/tests/integration/forum.routes.test.ts`
- [X] T012 [P] [US1] Unit and BLoC tests for forum repository and BLoC in `frontend/test/unit/forum_repository_test.dart` and `frontend/test/bloc/forum_bloc_test.dart`
- [X] T013 [P] [US1] Widget and accessibility tests for category cards and topic tiles (verifying touch targets >= 48x48 dp and TalkBack/VoiceOver semantics) in `frontend/test/widget/forum_topic_tile_test.dart`

### Implementation for User Story 1

- [X] T014 [US1] Implement forum service core (categories listing/CRUD, topics listing with sorting/filters, topic creation, and atomic topic like toggle) in `backend/src/modules/forum/forum.service.ts`
- [X] T015 [US1] Implement Fastify route handlers for categories and topics endpoints in `backend/src/modules/forum/forum.routes.ts`
- [X] T016 [P] [US1] Implement repository methods for categories and topics with Dio in `frontend/lib/data/repositories/forum_repository_impl.dart`
- [X] T017 [US1] Implement `ForumBloc`, events, and states for category browsing, topic listing, topic creation, and like toggle in `frontend/lib/presentation/bloc/forum/forum_bloc.dart`, `frontend/lib/presentation/bloc/forum/forum_event.dart`, and `frontend/lib/presentation/bloc/forum/forum_state.dart`
- [X] T018 [P] [US1] Implement accessible `ForumCategoryCard` component in `frontend/lib/presentation/components/forum_category_card.dart`
- [X] T019 [P] [US1] Implement accessible `ForumTopicTile` component with category badges, visibility indicators, and like counters in `frontend/lib/presentation/components/forum_topic_tile.dart`
- [X] T020 [US1] Implement forum home view with categories grid and highlighted topics in `frontend/lib/presentation/views/forum/forum_home_view.dart`
- [X] T021 [US1] Implement category topics view with search and sort filters (recent, most liked, most commented) in `frontend/lib/presentation/views/forum/category_topics_view.dart`
- [X] T022 [US1] Implement accessible topic creation view with category selector, content inputs, and visibility selector in `frontend/lib/presentation/views/forum/create_topic_view.dart`
- [X] T023 [US1] Integrate Forum navigation entry in `frontend/lib/presentation/views/home/main_navigation_screen.dart` and register repository dependency in `frontend/lib/main.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently as the initial MVP!

---

## Phase 4: User Story 2 - Comentários e Respostas Aninhadas em Subthreads (Priority: P2)

**Goal**: Permitir que usuários autenticados respondam a tópicos e comentários criando subthreads hierárquicas até 3 níveis de profundidade, com achatamento visual subsequente com citação explícita (`@usuario`), controle de visibilidade da resposta e capacidade de recolher/expandir galhos de discussão.

**Independent Test**: Publicar comentários de nível 1 em um tópico, responder a um comentário criando nível 2 e nível 3, verificar a renderização do recuo visual e menção `@usuario`, testar o botão de colapsar/expandir a subthread e curtir comentários.

### Tests for User Story 2 (MANDATORY - >= 80% coverage + Accessibility) ⚠️

- [X] T024 [P] [US2] Unit tests for comments tree nesting, depth calculation (max 3), ceiling rule visibility inheritance, and comment like toggle in `backend/tests/unit/forum.service.test.ts`
- [X] T025 [P] [US2] Integration tests for comment creation and nested comments retrieval in `backend/tests/integration/forum.routes.test.ts`
- [X] T026 [P] [US2] Widget and accessibility tests for nested comment threads, depth indentations, and collapse/expand semantics in `frontend/test/widget/forum_comment_thread_test.dart`

### Implementation for User Story 2

- [X] T027 [US2] Implement comment service methods (tree building, depth assignment up to 3, reply mention resolution, ceiling rule validation, and comment like toggle) in `backend/src/modules/forum/forum.service.ts`
- [X] T028 [US2] Implement Fastify routes for topic comments (`POST /topics/:id/comments`, `GET /topics/:id/comments`, `POST /comments/:id/like`) in `backend/src/modules/forum/forum.routes.ts`
- [X] T029 [P] [US2] Add comment fetching, comment creation, and comment like toggle methods in `frontend/lib/data/repositories/forum_repository_impl.dart`
- [X] T030 [P] [US2] Implement accessible `SubthreadCollapseToggle` button with min 48x48 dp touch target and Semantics in `frontend/lib/presentation/components/subthread_collapse_toggle.dart`
- [X] T031 [US2] Implement recursive/flattened `ForumCommentThread` widget supporting visual nesting up to 3 levels, reply citation badge, and collapse state in `frontend/lib/presentation/components/forum_comment_thread.dart`
- [X] T032 [US2] Update `ForumBloc` with comment submission, branch collapsing/expanding, and comment liking events in `frontend/lib/presentation/bloc/forum/forum_bloc.dart`
- [X] T033 [US2] Implement topic detail view displaying topic content, comments tree, and reply input bar with visibility selector in `frontend/lib/presentation/views/forum/topic_detail_view.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently.

---

## Phase 5: User Story 3 - Visualização e Navegação Pública para Visitantes Anônimos (Priority: P3)

**Goal**: Permitir que visitantes não cadastrados naveguem por categorias, leiam tópicos e comentários com visibilidade `PUBLIC` com resposta rápida (< 2s), garantindo zero vazamento de itens restritos e solicitando login amigavelmente para interações.

**Independent Test**: Acessar o fórum como visitante anônimo (sem header `Authorization`), verificar se apenas tópicos e comentários `PUBLIC` são exibidos, confirmar que tópicos/comentários `COMMUNITY` e `AUTHOR` são estritamente ocultados e que tentar interagir abre o convite de login.

### Tests for User Story 3 (MANDATORY - >= 80% coverage + Accessibility) ⚠️

- [X] T034 [P] [US3] Integration and security tests verifying anonymous guest access, public data filtering, and 100% isolation of `COMMUNITY` and `AUTHOR` content in `backend/tests/integration/forum.routes.test.ts`
- [X] T035 [P] [US3] Widget tests for guest interaction prompting login dialog in `frontend/test/widget/forum_guest_access_test.dart`

### Implementation for User Story 3

- [X] T036 [US3] Enforce guest database filter queries in `backend/src/modules/forum/forum.service.ts` to strictly exclude non-public topics and comments when no user is authenticated
- [X] T037 [US3] Configure optional JWT authentication middleware on public GET routes (`/categories`, `/topics`, `/topics/:id`, `/topics/:id/comments`) in `backend/src/modules/forum/forum.routes.ts`
- [X] T038 [US3] Integrate guest action interceptor and `GuestActionDialog` for unauthenticated attempts to create topics, comment, or like in `frontend/lib/presentation/views/forum/topic_detail_view.dart` and `frontend/lib/presentation/views/forum/category_topics_view.dart`

**Checkpoint**: At this point, User Stories 1, 2, and 3 work seamlessly together with strict privacy boundaries.

---

## Phase 6: User Story 4 - Gerenciamento de Conteúdo, Exclusão Segura e Moderação (Priority: P4)

**Goal**: Permitir edição de tópicos e comentários com indicador visual (`is_edited`), exclusão segura por soft-delete (preservando subthreads filhas e substituindo conteúdo por `"[Comentário removido pelo autor]"` com desvinculação de PII conforme LGPD), e denúncia comunitária de conteúdos impróprios.

**Independent Test**: Editar uma mensagem e validar selo de edição; excluir um comentário que possui filhos e verificar que a subthread permanece intacta com texto e autor sanitizados; registrar denúncia de conteúdo impróprio e validar resposta da moderação.

### Tests for User Story 4 (MANDATORY - >= 80% coverage + Accessibility) ⚠️

- [X] T039 [P] [US4] Unit tests for topic/comment editing, soft-delete with tree preservation, author PII redaction (LGPD), and report submission in `backend/tests/unit/forum.service.test.ts`
- [X] T040 [P] [US4] Integration tests for PATCH/DELETE topic and comment endpoints and content reporting in `backend/tests/integration/forum.routes.test.ts`
- [X] T041 [P] [US4] Widget tests for edited indicator, sanitized comment placeholders, and content reporting dialog in `frontend/test/widget/forum_moderation_test.dart`

### Implementation for User Story 4

- [X] T042 [US4] Implement topic and comment update service methods (`PATCH`) setting `is_edited: true` and `edited_at` in `backend/src/modules/forum/forum.service.ts`
- [X] T043 [US4] Implement secure soft-delete service methods (`DELETE`) preserving child subthreads with `[Comentário removido pelo autor]` and author de-identification in `backend/src/modules/forum/forum.service.ts`
- [X] T044 [US4] Implement Fastify route handlers for PATCH/DELETE topics and comments in `backend/src/modules/forum/forum.routes.ts`
- [X] T045 [P] [US4] Add update, delete, and report methods to repository in `frontend/lib/data/repositories/forum_repository_impl.dart`
- [X] T046 [US4] Update `ForumBloc` with edit, delete, and report handlers in `frontend/lib/presentation/bloc/forum/forum_bloc.dart`
- [X] T047 [US4] Implement post edit modal dialog and integrate `ContentReportDialog` for forum topics and comments in `frontend/lib/presentation/views/forum/topic_detail_view.dart`

**Checkpoint**: All user stories should now be independently functional and compliant with LGPD and WCAG 2.1 AA.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Documentation validation, performance benchmarks, and end-to-end audit

- [X] T048 [P] Add OpenAPI schema compliance tests against `specs/002-forum-topics-discussions/contracts/openapi.yaml` in `backend/tests/integration/forum_openapi.test.ts`
- [X] T049 [P] Performance benchmark test verifying P95 < 150ms for topic queries and public payload loads in `backend/tests/unit/forum_performance.test.ts`
- [X] T050 Validate end-to-end local environment setup and testing workflows following `specs/002-forum-topics-discussions/quickstart.md`
- [X] T051 Accessibility semantics audit and touch target compliance verification (WCAG 2.1 AA) across all forum components in `frontend/test/widget/forum_accessibility_audit_test.dart`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User Story 1 (P1): Can start immediately after Phase 2 (MVP)
  - User Story 2 (P2): Depends on Phase 2 and topic entity from US1
  - User Story 3 (P3): Depends on Phase 2 and public read access from US1/US2
  - User Story 4 (P4): Depends on Phase 2 and topic/comment entities from US1/US2
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

```
[Phase 1: Setup]
       │
       ▼
[Phase 2: Foundational]
       │
       ├────────────────────────────────────────┐
       ▼                                        ▼
[Phase 3: User Story 1 (P1)]            [Phase 4: User Story 2 (P2)]
 (Categories & Topics MVP)               (Comments & Subthreads)
       │                                        │
       └───────────────────┬────────────────────┘
                           ▼
              [Phase 5: User Story 3 (P3)]
               (Public Guest Browsing)
                           │
                           ▼
              [Phase 6: User Story 4 (P4)]
              (Editing, LGPD Soft-Delete & Reports)
                           │
                           ▼
              [Phase 7: Polish & Audit]
```

### Within Each User Story

- Tests MUST be written FIRST and fail before implementation
- Models and schemas before service logic
- Service logic before routes and repositories
- Repositories and BLoC before UI views
- Story verified independently before closing

### Parallel Opportunities

- **Phase 1**: T003 (Prisma migration) and T004 (seed script) can run in parallel
- **Phase 2**: T007 (repository interface) and T008 (VisibilityBadge component) can run in parallel
- **Phase 3 (US1)**:
  - T010, T011, T012, T013 (all tests) can run in parallel
  - T016, T018, T019 (Flutter repo, category card, topic tile) can run in parallel
- **Phase 4 (US2)**:
  - T024, T025, T026 (tests) can run in parallel
  - T029, T030 (Flutter repo and collapse toggle) can run in parallel
- **Phase 5 (US3)**:
  - T034, T035 (security and guest widget tests) can run in parallel
- **Phase 6 (US4)**:
  - T039, T040, T041 (unit, integration, widget tests) can run in parallel
  - T045 (Flutter repo update) can run in parallel with backend endpoints
- **Phase 7**: T048, T049 can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit tests for topic visibility rules, category management, sorting filters, and topic likes in backend/tests/unit/forum.service.test.ts"
Task: "Integration tests for categories and topics endpoints in backend/tests/integration/forum.routes.test.ts"
Task: "Unit and BLoC tests for forum repository and BLoC in frontend/test/unit/forum_repository_test.dart and frontend/test/bloc/forum_bloc_test.dart"
Task: "Widget and accessibility tests for category cards and topic tiles in frontend/test/widget/forum_topic_tile_test.dart"

# Launch independent UI components for User Story 1 together:
Task: "Implement accessible ForumCategoryCard component in frontend/lib/presentation/components/forum_category_card.dart"
Task: "Implement accessible ForumTopicTile component with category badges in frontend/lib/presentation/components/forum_topic_tile.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T009)
3. Complete Phase 3: User Story 1 (T010-T023)
4. **STOP and VALIDATE**: Verify that categories and topics can be created, browsed, and liked independently.
5. Deliver/demo as initial MVP!

### Incremental Delivery

1. Setup + Foundational → Database schema and contracts ready
2. Add User Story 1 (P1) → Categories, topics, and initial debates functional (MVP)
3. Add User Story 2 (P2) → Multi-level subthreads, replies, and discussion depth enabled
4. Add User Story 3 (P3) → Guest visitor discovery with zero data leakage
5. Add User Story 4 (P4) → Full LGPD compliance, safe soft-delete, and community reports
6. Polish & Audit → Performance P95 < 150ms and WCAG 2.1 AA accessibility guaranteed

---

## Notes

- `[P]` tasks = different files, no dependencies
- `[Story]` label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Strict adherence to Constitution Principle III: Tests are mandatory and must be verified before declaring tasks complete
- All touch targets >= 48x48 dp, contrast >= 4.5:1, and screen reader announcements compliant with WCAG 2.1 AA
