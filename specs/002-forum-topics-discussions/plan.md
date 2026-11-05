# Implementation Plan: Espaço de Debate e Fórum de Tópicos Categorizados

**Branch**: `002-forum-topics-discussions` | **Date**: 2026-11-04 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/002-forum-topics-discussions/spec.md`  

---

## Summary

Esta funcionalidade implementa o **Espaço de Debate e Fórum de Tópicos Categorizados** do DáPraIr?, permitindo que a comunidade e visitantes compartilhem experiências, debatam soluções de acessibilidade e interajam de forma estruturada:
1. **Catálogo Curado de Categorias**: Categorias temáticas gerenciadas exclusivamente por administradores para organização dos debates.
2. **Controle Granular de Visibilidade em 3 Níveis**: Tópicos e comentários com visibilidade `PUBLIC` (aberto a visitantes anônimos e indexação), `COMMUNITY` (restrito a usuários autenticados) e `AUTHOR` (privado ao autor no caso de tópicos, ou diálogo privado contextual entre o autor do comentário e o autor do tópico). O tópico atua como teto de privacidade (regra do teto / ceiling rule).
3. **Subthreads Hierárquicas até 3 Níveis**: Comentários estruturados em árvore aninhada até 3 níveis de profundidade, com achatamento visual subsequente com citação explícita (`@usuario`), capacidade de recolher/expandir galhos de discussão e indicação semântica completa para leitores de tela.
4. **Interações Comunitárias e Moderação**: Curtida simples (upvote) com contadores em tempo real para tópicos e comentários, canal de denúncias integrado a administradores com motivos padronizados.
5. **Conformidade LGPD e Integridade Estrutural**: Edição com sinalização visual e exclusão segura por soft-delete (preservando subthreads de terceiros com redação de PII para `"[Comentário removido pelo autor]"`), sem deixar nós órfãos.

---

## Technical Context

**Language/Version**: TypeScript 5.4+ (Node.js 20 LTS) & Dart 3.5+ (Flutter 3.24+)  
**Primary Dependencies**:
- *Backend*: Fastify 4.28+, `@fastify/jwt`, `@fastify/sensible`, Prisma ORM 5.21+, Zod 3.23+, Argon2id
- *Frontend*: Flutter SDK, `flutter_bloc`, `dio`, `equatable`, `intl`
**Storage**: PostgreSQL 16 (relacional com índices otimizados para consultas cronológicas e de popularidade)  
**Testing**:
- *Backend*: Vitest, Supertest, cobertura mínima de 80%
- *Frontend*: `flutter_test`, `bloc_test`, testes de semântica com `tester.getSemantics()` (WCAG 2.1 AA)
**Target Platform**: Multiplataforma: Android (API 26+), iOS (15+), Navegadores Web modernos, Linux container (Docker)  
**Project Type**: Full-stack Mobile/Web application + API REST  
**Performance Goals**:
- Listagem e leitura de tópicos/comentários públicos por visitantes < 2 segundos em rede móvel (SC-001)
- Resposta de API P95 < 150ms para consultas de tópicos e árvore de comentários
**Constraints**:
- Acessibilidade WCAG 2.1 AA obrigatória em 100% dos componentes de subthread e formulários (alvos de toque >= 48x48 dp, contraste >= 4.5:1, semântica TalkBack/VoiceOver)
- Privacidade por Padrão / LGPD: Bloqueio estrito de vazamento de tópicos/comentários comunitários ou privados para visitantes anônimos (SC-002)
- Integridade estrutural: 100% de preservação de nós subordinados em exclusões com filhas ativas (SC-005)
**Scale/Scope**:
- Suporte a milhares de tópicos e dezenas de milhares de mensagens com queries indexadas e paginação eficiente

---

## Constitution Check

*GATE: All gates evaluated and verified post-design.*

- [x] **Gate 1 - Acessibilidade Universal (WCAG 2.1 AA/AAA)**: O design especifica suporte integral a leitores de tela (`Semantics`), anunciando nível da subthread ("Resposta nível X a @usuario"), status de expansão/recolhimento e badges de visibilidade com alto contraste (>= 4.5:1). Alvos de toque >= 48x48 dp e fontes escaláveis garantidos.
- [x] **Gate 2 - Código Limpo e Componentização**: Clean Architecture respeitada no backend (módulo isolado `modules/forum/` com rotas, schemas Zod e serviço) e frontend Flutter (separação estrita em `domain/entities`, `domain/repositories`, `data/repositories`, `presentation/bloc`, `presentation/views`, `presentation/components`).
- [x] **Gate 3 - Testabilidade e Alta Cobertura (>= 80%)**: O plano estabelece suítes de testes unitários de casos de uso/serviços, testes de integração de API Fastify cobrindo regras de visibilidade e soft-delete, testes de BloC e testes de widgets Flutter validando semântica acessível.
- [x] **Gate 4 - Privacidade e LGPD**: Minimização de dados aplicada (apenas id, texto, timestamps, visibilidade). Tópicos e comentários restritos filtrados diretamente nas consultas do banco. Anonimização/redação de PII na exclusão com integridade de subthreads preservada.
- [x] **Gate 5 - Consistência Multiplataforma e Docker**: Código unificado Flutter para Web, Android e iOS. Backend Node.js + Prisma orquestrado via Docker Compose com migrações versionadas.

---

## Project Structure

### Documentation (this feature)

```text
specs/002-forum-topics-discussions/
├── spec.md              # Especificação de requisitos funcionais e clarificações aprovadas
├── plan.md              # Este plano de implementação técnica e engenharia
├── research.md          # Pesquisa técnica e resoluções de arquitetura (Phase 0)
├── data-model.md        # Modelagem de dados, tabelas relacionais e regras de estado (Phase 1)
├── quickstart.md        # Guia de inicialização local, migrações e comandos de teste (Phase 1)
├── contracts/           # Contratos de interface OpenAPI 3.1
│   └── openapi.yaml     # Especificação completa dos endpoints de fórum, tópicos e comentários
└── tasks.md             # Decomposição em tarefas executáveis (Phase 2 - speckit-tasks)
```

### Source Code (repository root)

```text
backend/
├── prisma/
│   ├── schema.prisma                  # Atualização com ForumCategory, ForumTopic, ForumComment, ForumTopicLike, ForumCommentLike
│   └── migrations/                    # Nova migração SQL versionada para tabelas do fórum
├── src/
│   ├── modules/
│   │   └── forum/                     # Novo módulo completo de fórum
│   │       ├── forum.schemas.ts       # Schemas de validação Zod (criação, filtros, paginação)
│   │       ├── forum.service.ts       # Regras de negócio, visibilidade contextual, likes, subthreads e LGPD
│   │       └── forum.routes.ts        # Endpoints Fastify (/api/v1/forum)
│   └── server.ts                      # Registro do módulo de fórum
└── tests/
    ├── unit/
    │   └── forum.service.test.ts      # Testes unitários de regras de visibilidade e aninhamento
    └── integration/
        └── forum.routes.test.ts       # Testes de integração de endpoints Fastify e moderação

frontend/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── forum_category.dart    # Entidade de categoria temática
│   │   │   ├── forum_topic.dart       # Entidade de tópico com autor e contadores
│   │   │   └── forum_comment.dart     # Entidade de comentário com subthreads
│   │   └── repositories/
│   │       └── forum_repository.dart  # Contrato abstrato do repositório
│   ├── data/
│   │   └── repositories/
│   │       └── forum_repository_impl.dart # Implementação com Dio e tratamento de erros
│   └── presentation/
│       ├── bloc/
│       │   └── forum/                 # Gestão de estado BloC (carregamento, likes, envio de respostas)
│       │       ├── forum_bloc.dart
│       │       ├── forum_event.dart
│       │       └── forum_state.dart
│       ├── components/
│       │   ├── forum_category_card.dart     # Card acessível de categoria
│       │   ├── forum_topic_tile.dart        # Item da listagem de tópicos
│       │   ├── forum_comment_thread.dart    # Componente recursivo até nível 3 com recuo e citação
│       │   ├── visibility_badge.dart        # Badge de visibilidade com alto contraste
│       │   └── subthread_collapse_toggle.dart # Botão 48x48 dp de expandir/recolher com semântica
│       └── views/
│           └── forum/
│               ├── forum_home_view.dart     # Tela inicial com categorias e tópicos em destaque
│               ├── category_topics_view.dart# Listagem de tópicos por categoria com filtros
│               ├── topic_detail_view.dart   # Leitura do tópico e árvore de comentários
│               └── create_topic_view.dart   # Formulário acessível para abertura de novo debate
└── test/
    ├── unit/
    │   └── forum_repository_test.dart
    ├── bloc/
    │   └── forum_bloc_test.dart
    └── widget/
        ├── forum_comment_thread_test.dart   # Asserção da árvore semântica WCAG 2.1 AA
        └── forum_topic_tile_test.dart
```

**Structure Decision**: Padrão de monorepo desacoplado com Clean Architecture (módulo isolado `backend/src/modules/forum/` e estrutura em camadas no `frontend/lib/`).

---

## Complexity Tracking

> **Sem violações constitucionais**. Todas as decisões técnicas seguem diretamente os princípios fundamentais da Constituição do DáPraIr? (WCAG 2.1 AA, Clean Code, Testes >= 80%, LGPD e Docker).
