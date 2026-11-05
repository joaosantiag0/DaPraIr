---
description: "Task list for admin control panel and moderation feature implementation"
---

# Tasks: Painel de Controle Administrativo e Central de Moderação

**Input**: Design documents from `/specs/004-admin-moderation-panel/`  
**Prerequisites**: [plan.md](./plan.md) (required), [spec.md](./spec.md) (required), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/openapi.yaml](./contracts/openapi.yaml), [quickstart.md](./quickstart.md)  

**Tests**: Testes são OBRIGATÓRIOS conforme a Constituição DáPraIr? (Princípio III: Testabilidade Contínua e Alta Cobertura >= 80%). Cada história de usuário contempla testes unitários, testes de integração de API e testes de widgets/acessibilidade WCAG 2.1 AA.

**Organization**: Tarefas agrupadas por histórias de usuário priorizadas para permitir entrega incremental e testabilidade independente.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Tarefa paralelizável (arquivos distintos, sem dependência de tarefas incompletas)
- **[Story]**: Mapeamento para a respectiva User Story (`US1`, `US2`, `US3`, `US4`)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Inicialização da infraestrutura compartilhada, migrações de dados e estrutura de diretórios.

- [X] T001 Atualizar modelo Prisma com `ModerationAction`, `UserPenalty` e campos em `User`/`ContentReport` em `backend/prisma/schema.prisma`
- [X] T002 Gerar cliente Prisma e aplicar migração versionada do banco de dados em `backend/prisma/migrations/`
- [X] T003 [P] Criar estrutura de diretórios do módulo administrativo backend em `backend/src/modules/admin/`
- [X] T004 [P] Criar estrutura de diretórios de administração no frontend Flutter em `frontend/lib/presentation/views/admin/` e `frontend/lib/presentation/bloc/admin/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Infraestrutura crítica de autenticação RBAC, guards de segurança e clientes de comunicação.

**⚠️ CRITICAL**: Nenhuma história de usuário pode ser finalizada sem a conclusão desta fase.

- [X] T005 [P] Implementar middleware de autorização RBAC (`requireAdminOrModerator`) e verificação de `session_invalidated_at` em `backend/src/modules/admin/admin.middleware.ts`
- [X] T006 [P] Implementar serviço utilitário de gravação de logs de auditoria imutáveis em `backend/src/modules/admin/audit.service.ts`
- [X] T007 [P] Configurar interceptor HTTP no cliente Dio para captura de `SESSION_REVOKED` e logout forçado em `frontend/lib/core/network/admin_api_client.dart`
- [X] T008 Registrar rotas do módulo admin e prefixo `/api/v1/admin` no servidor Fastify em `backend/src/server.ts`

**Checkpoint**: Base de segurança RBAC e banco de dados pronta — implementação das histórias de usuário desbloqueada.

---

## Phase 3: User Story 1 - Triagem e Tratamento da Fila de Denúncias (Priority: P1) 🎯 MVP

**Goal**: Permitir que administradores e moderadores acessem a fila de denúncias da comunidade, inspecionem o conteúdo em contexto e resolvam as denúncias (aceitando para moderação ou rejeitando como improcedente com justificativa formal).

**Independent Test**: Pode ser testado gerando uma denúncia no banco, autenticando com perfil de moderador, abrindo a fila de denúncias no painel, inspecionando detalhes e executando resolução com justificativa, confirmando a atualização de status e gravação de log.

### Tests for User Story 1 (MANDATORY - >= 80% coverage + Accessibility) ⚠️
- [X] T009 [P] [US1] Teste unitário para filtros e resolução da fila de denúncias em `backend/tests/unit/reports_queue.service.test.ts`
- [X] T010 [P] [US1] Teste de integração para endpoints `GET /api/v1/admin/reports` e `PATCH /api/v1/admin/reports/:id` em `backend/tests/integration/admin_reports.routes.test.ts`
- [X] T011 [P] [US1] Testes de widget e acessibilidade (`Semantics`) para `AdminReportsQueueView` em `frontend/test/widget/admin_reports_queue_test.dart`

### Implementation for User Story 1
- [X] T012 [P] [US1] Definir schemas Zod de listagem e resolução de denúncias em `backend/src/modules/admin/admin.schemas.ts`
- [X] T013 [US1] Implementar listagem paginada, inspeção detalhada e resolução de denúncias em `backend/src/modules/admin/admin.service.ts`
- [X] T014 [US1] Configurar rotas Fastify de denúncias (`GET /reports`, `GET /reports/:id`, `PATCH /reports/:id`) em `backend/src/modules/admin/admin.routes.ts`
- [X] T015 [P] [US1] Criar entidade `ContentReport` e contrato de repositório em `frontend/lib/domain/entities/content_report.dart` e `frontend/lib/domain/repositories/admin_repository.dart`
- [X] T016 [US1] Implementar métodos de denúncias no repositório de dados em `frontend/lib/data/repositories/admin_repository_impl.dart`
- [X] T017 [US1] Implementar BLoC de fila de denúncias (`AdminReportsBloc`) em `frontend/lib/presentation/bloc/admin/admin_reports_bloc.dart`
- [X] T018 [US1] Construir tela acessível `AdminReportsQueueView` com badges de alto contraste e alvos >= 48dp em `frontend/lib/presentation/views/admin/admin_reports_queue_view.dart`

**Checkpoint**: User Story 1 (MVP) completamente funcional e testável de ponta a ponta.

---

## Phase 4: User Story 2 - Gestão e Moderação de Conteúdos Postados (Priority: P2)

**Goal**: Disponibilizar catálogo unificado de publicações (fórum, comentários, avaliações, mídias) com capacidade de busca textual e ações de ocultação (reversível) e exclusão com cascata total em tópicos.

**Independent Test**: Pode ser testado pesquisando um tópico por texto, ocultando o tópico e validando que ele e suas subthreads saem da visualização pública, e restaurando ou excluindo em definitivo com registro de auditoria.

### Tests for User Story 2 (MANDATORY - >= 80% coverage + Accessibility) ⚠️
- [X] T019 [P] [US2] Teste unitário para ocultação e exclusão atômica em cascata de tópicos e respostas em `backend/tests/unit/content_moderation.service.test.ts`
- [X] T020 [P] [US2] Teste de integração para endpoints de busca e moderação de conteúdo em `backend/tests/integration/admin_content.routes.test.ts`
- [X] T021 [P] [US2] Testes de widget e foco assistivo para `AdminContentView` em `frontend/test/widget/admin_content_view_test.dart`

### Implementation for User Story 2
- [X] T022 [P] [US2] Definir schemas Zod para busca unificada, ocultação e exclusão com confirmação em `backend/src/modules/admin/admin.schemas.ts`
- [X] T023 [US2] Implementar busca unificada e ações de ocultar, restaurar e excluir em cascata via transação Prisma em `backend/src/modules/admin/admin.service.ts`
- [X] T024 [US2] Expor endpoints de moderação de conteúdo (`GET /content`, `PATCH /content/:type/:id/hide`, `PATCH /content/:type/:id/restore`, `DELETE /content/:type/:id`) em `backend/src/modules/admin/admin.routes.ts`
- [X] T025 [P] [US2] Criar entidade `UnifiedContent` e modelos de dados em `frontend/lib/domain/entities/unified_content.dart`
- [X] T026 [US2] Implementar chamadas de moderação de conteúdo no repositório Flutter em `frontend/lib/data/repositories/admin_repository_impl.dart`
- [X] T027 [US2] Implementar BLoC de moderação de conteúdos (`AdminContentBloc`) em `frontend/lib/presentation/bloc/admin/admin_content_bloc.dart`
- [X] T028 [US2] Construir `AdminContentView` com filtros por tipo, busca de texto e diálogos de confirmação acessíveis em `frontend/lib/presentation/views/admin/admin_content_view.dart`

**Checkpoint**: User Stories 1 e 2 plenamente operacionais de forma integrada.

---

## Phase 5: User Story 3 - Gestão de Usuários, Aplicação de Sanções e Banimento (Priority: P3)

**Goal**: Fornecer busca e perfil de usuários, aplicação de sanções progressivas (advertência, suspensão temporária de 7 dias com contagem automática, banimento definitivo) e encerramento imediato de sessões.

**Independent Test**: Pode ser testado localizando um usuário infrator, aplicando penalidade de suspensão de 7 dias ou banimento, tentando efetuar requisição com o token anterior do usuário e validando a rejeição imediata com código 401.

### Tests for User Story 3 (MANDATORY - >= 80% coverage + Accessibility) ⚠️
- [X] T029 [P] [US3] Teste unitário para escalonamento progressivo de penalidades e expiração em `backend/tests/unit/user_penalties.service.test.ts`
- [X] T030 [P] [US3] Teste de integração para aplicação e revogação de penalidades em `backend/tests/integration/admin_users.routes.test.ts`
- [X] T031 [P] [US3] Testes de widget e leitores de tela para `AdminUsersView` em `frontend/test/widget/admin_users_view_test.dart`

### Implementation for User Story 3
- [X] T032 [P] [US3] Definir schemas Zod para aplicação e revogação de sanções em `backend/src/modules/admin/admin.schemas.ts`
- [X] T033 [US3] Implementar cálculo de penalidades progressivas, invalidação de `session_invalidated_at` e revogação em `backend/src/modules/admin/admin.service.ts`
- [X] T034 [US3] Expor rotas de gestão de usuários (`GET /users`, `GET /users/:id`, `POST /users/:id/penalties`, `DELETE /users/:id/penalties/:penaltyId`) em `backend/src/modules/admin/admin.routes.ts`
- [X] T035 [P] [US3] Criar entidades `UserPenalty` e `AdminUserSummary` em `frontend/lib/domain/entities/user_penalty.dart`
- [X] T036 [US3] Implementar métodos de gestão de usuários no repositório Flutter em `frontend/lib/data/repositories/admin_repository_impl.dart`
- [X] T037 [US3] Implementar BLoC de usuários e sanções (`AdminUsersBloc`) em `frontend/lib/presentation/bloc/admin/admin_users_bloc.dart`
- [X] T038 [US3] Construir `AdminUsersView` com ficha de perfil, histórico de denúncias e modal acessível de aplicação de sanções em `frontend/lib/presentation/views/admin/admin_users_view.dart`

**Checkpoint**: Controle completo de usuários e sanções ativo com segurança garantida.

---

## Phase 6: User Story 4 - Trilha de Auditoria e Governança de Moderação (Priority: P4)

**Goal**: Garantir a consulta transparente e imutável de todas as ações moderadoras executadas no sistema, com filtros por período e moderador, atendendo à LGPD e auditoria legal.

**Independent Test**: Pode ser testado executando ações de moderação prévias, abrindo a tela de auditoria, aplicando filtros por data/ação e verificando que cada evento contém carimbo de data/hora, justificativa e autor correto.

### Tests for User Story 4 (MANDATORY - >= 80% coverage + Accessibility) ⚠️
- [X] T039 [P] [US4] Teste unitário de persistência e consulta imutável de auditoria em `backend/tests/unit/audit_logs.service.test.ts`
- [X] T040 [P] [US4] Teste de integração para `GET /api/v1/admin/audit-logs` em `backend/tests/integration/admin_audit.routes.test.ts`
- [X] T041 [P] [US4] Testes de widget para `AdminAuditView` com suporte a leitor de tela em `frontend/test/widget/admin_audit_view_test.dart`

### Implementation for User Story 4
- [X] T042 [P] [US4] Definir schemas Zod para filtros de trilha de auditoria em `backend/src/modules/admin/admin.schemas.ts`
- [X] T043 [US4] Implementar consulta paginada de logs de auditoria com metadados contextuais em `backend/src/modules/admin/admin.service.ts`
- [X] T044 [US4] Expor rota de consulta `GET /api/v1/admin/audit-logs` em `backend/src/modules/admin/admin.routes.ts`
- [X] T045 [P] [US4] Criar entidade `ModerationAction` em `frontend/lib/domain/entities/moderation_action.dart`
- [X] T046 [US4] Implementar consulta de auditoria no repositório Flutter em `frontend/lib/data/repositories/admin_repository_impl.dart`
- [X] T047 [US4] Implementar BLoC de auditoria (`AdminAuditBloc`) em `frontend/lib/presentation/bloc/admin/admin_audit_bloc.dart`
- [X] T048 [US4] Construir visualização acessível de linha do tempo `AdminAuditView` em `frontend/lib/presentation/views/admin/admin_audit_view.dart`

**Checkpoint**: Governança e auditoria 100% implementadas e em conformidade com a LGPD.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Unificação do painel administrativo, métricas gerais, roteamento e validação final de qualidade.

- [X] T049 Implementar dashboard mestre `AdminDashboardView` com cartões de estatísticas e navegação por abas em `frontend/lib/presentation/views/admin/admin_dashboard_view.dart`
- [X] T050 Expor endpoint de métricas consolidadas `GET /api/v1/admin/dashboard/stats` em `backend/src/modules/admin/admin.routes.ts`
- [X] T051 [P] Conectar atalho de acesso ao painel admin no menu de perfil do usuário autenticado em `frontend/lib/presentation/views/profile/profile_view.dart`
- [X] T052 Auditoria completa de acessibilidade WCAG 2.1 AA em todos os componentes administrativos (TalkBack, VoiceOver e navegação por teclado)
- [X] T053 Execução da validação de ponta a ponta guiada pelo roteiro de `specs/004-admin-moderation-panel/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies
- **Setup (Phase 1)**: Sem dependências — execução imediata.
- **Foundational (Phase 2)**: Depende do Setup — bloqueia todas as histórias de usuário.
- **User Story 1 (Phase 3 - MVP)**: Depende da Foundational (Phase 2).
- **User Story 2 (Phase 4)**: Depende da Foundational (Phase 2). Pode ser desenvolvida em paralelo à US1 ou sequencialmente.
- **User Story 3 (Phase 5)**: Depende da Foundational (Phase 2).
- **User Story 4 (Phase 6)**: Depende da gravação de ações de auditoria (T006).
- **Polish (Phase 7)**: Depende da conclusão das histórias de usuário prioritárias.

### Parallel Opportunities
- As tarefas de teste dentro de cada história de usuário marcadas com `[P]` podem ser escritas e executadas em paralelo.
- Schemas Zod e entidades Flutter marcadas com `[P]` podem ser desenvolvidos concomitantemente ao backend.
- As quatro histórias de usuário podem ser distribuídas entre múltiplos desenvolvedores assim que a Fase 2 (Foundational) for concluída.

---

## Parallel Example: User Story 1

```bash
# Executar testes da User Story 1 em paralelo:
Task: "T009 [P] [US1] Teste unitário para filtros e resolução da fila de denúncias em backend/tests/unit/reports_queue.service.test.ts"
Task: "T010 [P] [US1] Teste de integração para endpoints de denúncias em backend/tests/integration/admin_reports.routes.test.ts"
Task: "T011 [P] [US1] Testes de widget e acessibilidade para AdminReportsQueueView em frontend/test/widget/admin_reports_queue_test.dart"

# Desenvolver contratos e entidades em paralelo:
Task: "T012 [P] [US1] Definir schemas Zod de denúncias em backend/src/modules/admin/admin.schemas.ts"
Task: "T015 [P] [US1] Criar entidade ContentReport em frontend/lib/domain/entities/content_report.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Concluir **Fase 1 (Setup)** e **Fase 2 (Foundational)**.
2. Implementar **Fase 3 (User Story 1 - Fila de Denúncias)**.
3. **Validar MVP**: Testar a triagem de denúncias, aceitação e rejeição com gravação de auditoria.

### Entrega Incremental
1. **Incremento 1 (MVP)**: Fila e resolução de denúncias (US1).
2. **Incremento 2**: Moderação de conteúdos unificados e ação em cascata (US2).
3. **Incremento 3**: Controle de usuários e sanções progressivas com invalidação de sessão (US3).
4. **Incremento 4**: Consulta à trilha de auditoria e governança LGPD (US4).
5. **Incremento 5**: Dashboard unificado com métricas consolidadas (Polish).
