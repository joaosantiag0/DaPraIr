# Implementation Plan: Painel de Controle Administrativo e Central de Moderação

**Branch**: `004-admin-moderation-panel` | **Date**: 2026-11-05 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/004-admin-moderation-panel/spec.md`  

---

## Summary

Esta funcionalidade estabelece o **Painel de Controle Administrativo e Central de Moderação** unificado do DáPraIr?, permitindo que moderadores e administradores monitorem a comunidade, ajam rapidamente contra abusos e assegurem conformidade:
1. **Triagem Ágil de Denúncias**: Central de triagem de reportes comunitários com filtros por status, tipo e gravidade, permitindo aceitar com aplicação de sanção ou rejeitar de forma justificada.
2. **Moderação Unificada de Conteúdos**: Busca e gestão em catálogo unificado cobrindo Fórum (tópicos e respostas), Avaliações/Reviews de Acessibilidade de Locais e Fotos/Mídias enviadas, com ações de "Ocultar" (reversível) e "Excluir" (com cascata total em tópicos e suas subthreads).
3. **Escalonamento Progressivo de Penalidades e Banimento**: Gestão de contas com aplicação de sanções graduadas (1ª Advertência → 2ª Suspensão temporária de 7 dias → 3ª Banimento permanente definitivo; com banimento direto para casos gravíssimos), garantindo invalidação instantânea de sessões e tokens JWT (`session_invalidated_at`).
4. **Trilha de Auditoria Imutável**: Registro indelével de 100% dos atos de moderação com justificativa formal, assegurando transparência, governança interna e estrita aderência à LGPD (Art. 16).
5. **Acessibilidade Universal**: Interface administrativa responsiva em Flutter com conformidade integral à WCAG 2.1 AA (árvore semântica para leitores de tela, badges com alto contraste, alvos de toque >= 48x48 dp e suporte a zoom/alto contraste).

---

## Technical Context

**Language/Version**: TypeScript 5.4+ (Node.js 20 LTS) & Dart 3.5+ (Flutter 3.24+)  
**Primary Dependencies**:
- *Backend*: Fastify 4.28+, `@fastify/jwt`, `@fastify/sensible`, Prisma ORM 5.21+, Zod 3.23+, Argon2id
- *Frontend*: Flutter SDK, `flutter_bloc`, `dio`, `equatable`, `intl`, `flutter_secure_storage`
**Storage**: PostgreSQL 16 (tabelas relacionais `moderation_actions`, `user_penalties`, `content_reports`, com índices otimizados para filtros de auditoria e status)  
**Testing**:
- *Backend*: Vitest, Supertest, cobertura mínima obrigatória de 80% (linhas e branches)
- *Frontend*: `flutter_test`, `bloc_test`, testes de árvore de semântica com `tester.getSemantics()` (WCAG 2.1 AA)
**Target Platform**: Multiplataforma: Navegadores Web Desktop/Mobile, Android (API 26+), iOS (15+), Linux container (Docker)  
**Project Type**: Full-stack Web/Mobile application + API REST  
**Performance Goals**:
- Invalidação de sessões e tokens de usuários banidos/suspensos em menos de 2 segundos (SC-003)
- Ocultação imediata de conteúdos moderados nas queries públicas em 100% das consultas subsequentes (SC-004)
- Tempo de resposta da API de moderação P95 < 200ms
**Constraints**:
- Acessibilidade WCAG 2.1 AA obrigatória em todos os componentes e diálogos do painel (alvos de toque >= 48x48 dp, contraste >= 4.5:1, semântica TalkBack/VoiceOver)
- Privacidade e LGPD: Minimização e pseudonimização dos dados do denunciante, retenção de trilha de auditoria para obrigação legal (Art. 16, I da LGPD)
- Dupla confirmação e justificativa textual com mínimo de 10 caracteres em qualquer ação de moderação
**Scale/Scope**:
- Capacidade para gerenciar dezenas de milhares de publicações com paginação eficiente e busca textual indexada

---

## Constitution Check

*GATE: All gates evaluated and verified post-design.*

- [x] **Gate 1 - Acessibilidade Universal (WCAG 2.1 AA/AAA)**: Interface do painel em Flutter desenvolvida com semântica explícita (`Semantics`) para tabelas, modais de confirmação e botões de ação rápida. Badges de status (Pendente, Ocultado, Banido) com contraste superior a 4.5:1. Alvos mínimos de toque de 48x48 dp e total compatibilidade com leitores de tela e navegação por teclado.
- [x] **Gate 2 - Código Limpo e Componentização**: Clean Architecture respeitada no backend através do módulo isolado `backend/src/modules/admin/` (rotas, schemas Zod, serviços de moderação e auditoria) e no frontend Flutter (`presentation/views/admin/`, `presentation/bloc/admin/`, `data/repositories/admin_repository.dart`, `domain/entities/moderation/`).
- [x] **Gate 3 - Testabilidade e Alta Cobertura (>= 80%)**: Suíte de testes automatizados com cobertura >= 80% planejada: testes unitários de regras de escalonamento de penalidades, testes de integração Fastify para rotas protegidas por RBAC e testes de widgets/BLoC Flutter com validação de acessibilidade.
- [x] **Gate 4 - Privacidade e LGPD**: Minimização estrita de dados implementada; pseudonimização dos dados de denunciantes no painel; retenção fundamentada do log de auditoria `moderation_actions` em conformidade com o Art. 16 da LGPD, permitindo direito ao esquecimento nos dados pessoais do perfil sem quebra de integridade jurídica.
- [x] **Gate 5 - Consistência Multiplataforma e Docker**: Solução web/mobile unificada em Flutter integrada ao ecossistema conteinerizado (Docker Compose + Node.js + PostgreSQL) com migrações Prisma versionadas.

---

## Project Structure

### Documentation (this feature)

```text
specs/004-admin-moderation-panel/
├── spec.md              # Especificação formal com requisitos e decisões de esclarecimento
├── plan.md              # Este plano de arquitetura e implementação técnica
├── research.md          # Decisões de arquitetura, RBAC, cascata e LGPD (Phase 0)
├── data-model.md        # Modelagem de dados, esquemas Prisma e máquinas de estado (Phase 1)
├── quickstart.md        # Guia de inicialização, migrações e testes locais (Phase 1)
├── contracts/           # Contratos de interface OpenAPI 3.1
│   └── openapi.yaml     # Especificação completa dos endpoints de administração e moderação
└── tasks.md             # Decomposição de tarefas executáveis (Phase 2 - speckit-tasks)
```

### Source Code (repository root)

```text
backend/
├── prisma/
│   ├── schema.prisma                  # Atualização com ModerationAction, UserPenalty e campos em User/ContentReport
│   └── migrations/                    # Nova migração SQL versionada para tabelas de moderação
├── src/
│   ├── modules/
│   │   └── admin/                     # Novo módulo de administração e moderação
│   │       ├── admin.schemas.ts       # Validações Zod (filtros, penalidades, moderação, resolução)
│   │       ├── admin.service.ts       # Lógica de negócio: triagem, cascata, suspensão/banimento e auditoria
│   │       ├── admin.routes.ts        # Endpoints Fastify (/api/v1/admin/*)
│   │       └── admin.middleware.ts    # Guards de autorização RBAC (requireAdmin / requireModerator)
│   └── server.ts                      # Registro das rotas do módulo admin
└── tests/
    ├── unit/
    │   └── admin.service.test.ts      # Testes unitários de regras de moderação, penalidades e expiração
    └── integration/
        └── admin.routes.test.ts       # Testes de integração de endpoints protegidos por RBAC

frontend/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── content_report.dart    # Entidade de denúncia
│   │   │   ├── user_penalty.dart      # Entidade de penalidade/sanção
│   │   │   ├── moderation_action.dart # Entidade de log de auditoria
│   │   │   └── unified_content.dart   # Entidade abstrata de conteúdo moderável
│   │   └── repositories/
│   │       └── admin_repository.dart  # Contrato abstrato do repositório de moderação
│   ├── data/
│   │   ├── models/
│   │   │   ├── content_report_model.dart
│   │   │   ├── user_penalty_model.dart
│   │   │   └── moderation_action_model.dart
│   │   └── repositories/
│   │       └── admin_repository_impl.dart # Implementação com cliente Dio e tratamento de erros
│   └── presentation/
│       ├── bloc/
│       │   └── admin/
│       │       ├── admin_dashboard_bloc.dart # Gestão de estado do painel, filtros e ações
│       │       ├── admin_dashboard_event.dart
│       │       └── admin_dashboard_state.dart
│       └── views/
│           └── admin/
│               ├── admin_dashboard_view.dart      # Tela mestre com métricas e navegação por abas
│               ├── admin_reports_queue_view.dart  # Fila de denúncias
│               ├── admin_content_view.dart        # Gestão de conteúdos postados (ocultar/excluir)
│               ├── admin_users_view.dart          # Gestão de usuários e aplicação de penalidades
│               └── admin_audit_view.dart          # Consulta à trilha de auditoria
└── test/
    ├── unit/
    │   └── admin_bloc_test.dart       # Testes de estados do BLoC
    └── widget/
        └── admin_dashboard_test.dart  # Testes de widgets e semântica acessível (WCAG 2.1 AA)
```

**Structure Decision**: A solução preserva a arquitetura Clean Architecture existente no backend Fastify e no frontend Flutter, alocando a lógica em módulos desacoplados (`modules/admin/` e `views/admin/`). O banco de dados PostgreSQL orquestra a integridade de dados e as migrações através do Prisma ORM.

---

## Complexity Tracking

Não há violações aos princípios da Constituição que exijam justificativas adicionais. Todas as decisões técnicas adotam soluções nativas enxutas.
