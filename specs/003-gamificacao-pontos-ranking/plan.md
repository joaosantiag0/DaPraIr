# Implementation Plan: Sistema de Gamificação (Pontuação por Conteúdo e Ranking)

**Branch**: `003-gamificacao-pontos-ranking` | **Date**: 2026-11-05 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/003-gamificacao-pontos-ranking/spec.md`  

---

## Summary

Esta funcionalidade implementa o **Sistema de Gamificação e Ranking** do DáPraIr?, recompensando usuários por criarem e enriquecerem conteúdos de acessibilidade física e promovendo engajamento saudável por meio de reconhecimento comunitário:
1. **Pontuação Automática e Progressão por Qualidade**: Atribuição atômica e idempotente de pontos por criação de conteúdo (avaliações completas com notas de acessibilidade, bônus por fotos comprobatórias, bônus de utilidade comunitária e participação em tópicos/respostas do fórum).
2. **Ranking Multi-Período (Leaderboard)**: Abas de navegação temporal em tempo real com três visões (Semanal, Mensal e Geral), com destaque automático para a posição do usuário logado e acessibilidade total a visitantes não autenticados.
3. **Níveis de Engajamento e Extrato de Transações**: 5 níveis hierárquicos progressivos (Explorador a Embaixador), extrato detalhado de auditoria de pontos e estorno de pontos em caso de deleção ou infração de moderação.
4. **Privacidade e LGPD por Padrão (Opt-out)**: Controle do usuário para ativar modo pseudonimizado ("Usuário Anônimo") ou ocultar-se 100% do ranking público, com garantia de integridade do direito ao esquecimento.
5. **Acessibilidade Universal (WCAG 2.1 AA)**: Rótulos semânticos completos no Flutter (`Semantics`), contraste mínimo 4.5:1, alvos de toque >= 48x48 dp e distinção ordinal textual independente de cor.

---

## Technical Context

**Language/Version**: TypeScript 5.4+ (Node.js 20 LTS) & Dart 3.5+ (Flutter 3.24+)  
**Primary Dependencies**:
- *Backend*: Fastify 4.28+, `@fastify/jwt`, `@fastify/sensible`, Prisma ORM 5.21+, Zod 3.23+
- *Frontend*: Flutter SDK, `flutter_bloc`, `dio`, `equatable`, `intl`
**Storage**: PostgreSQL 16 (tabelas relacionais com transações ACID, chaves de unicidade para idempotência e índices B-tree compostos para queries de ranking)  
**Testing**:
- *Backend*: Vitest, Supertest, cobertura mínima de 80% (testes unitários de regras de pontos e integração de endpoints)
- *Frontend*: `flutter_test`, `bloc_test`, testes de semântica com `tester.getSemantics()` (WCAG 2.1 AA)
**Target Platform**: Multiplataforma: Android (API 26+), iOS (15+), Navegadores Web modernos, Linux container (Docker)  
**Project Type**: Full-stack Mobile/Web application + API REST  
**Performance Goals**:
- Notificação de pontuação em < 1s após publicação de conteúdo (SC-001)
- Carregamento do Leaderboard em < 1.5s em rede móvel 4G/5G (SC-002)
- Resposta de API P95 < 120ms para ranking e perfil de gamificação
**Constraints**:
- Acessibilidade WCAG 2.1 AA em 100% das telas e componentes de ranking, extrato e níveis
- Conformidade estrita com a LGPD (Princípio IV da Constituição): nenhum dado sensível de acessibilidade/saúde exposto no ranking público
- Respeito à política de privacidade com opt-out imediato e estornos íntegros
**Scale/Scope**:
- Suporte a dezenas de milhares de avaliações e consultas de ranking paginadas sem gargalos de concorrência

---

## Constitution Check

*GATE: All gates evaluated and verified post-design.*

- [x] **Gate 1 - Acessibilidade Universal (WCAG 2.1 AA/AAA)**: O design Flutter prevê anúncios semânticos claros para posições ordinais (ex: "1º lugar, Maria Silva, 420 pontos, Nível Mapeador"), alto contraste (>= 4.5:1), alvos de toque >= 48x48 dp nas abas de período e total desacoplamento de cor para identificar colocação.
- [x] **Gate 2 - Código Limpo e Componentização**: Clean Architecture respeitada no backend (novo módulo encapsulado `modules/gamification/` com rotas, schemas Zod e serviço) e frontend Flutter (separação estrita em `domain/entities`, `domain/repositories`, `data/repositories`, `presentation/bloc`, `presentation/views`, `presentation/components`).
- [x] **Gate 3 - Testabilidade e Alta Cobertura (>= 80%)**: Cobertura mandatória com testes unitários de cálculo de pontos, prevenção de duplicidade, estornos e limites diários anti-abuso, além de testes de integração Fastify e testes de widgets com semântica no Flutter.
- [x] **Gate 4 - Privacidade e LGPD**: Minimização rígida de dados no leaderboard (apenas nome público/apelido, avatar, pontos e nível). Configuração de privacidade de visibilidade com opção de ocultação e modo anônimo nativas.
- [x] **Gate 5 - Consistência Multiplataforma e Docker**: Solução 100% integrada ao `docker-compose.yml` e schema do Prisma versionado com migrações SQL oficiais.

---

## Project Structure

### Documentation (this feature)

```text
specs/003-gamificacao-pontos-ranking/
├── spec.md              # Especificação de requisitos funcionais e clarificações aprovadas
├── plan.md              # Este plano de implementação técnica e engenharia
├── research.md          # Pesquisa técnica, decisões de arquitetura e idempotência (Phase 0)
├── data-model.md        # Modelagem de dados, tabelas relacionais e regras de negócio (Phase 1)
├── quickstart.md        # Guia de inicialização local, migrações e comandos de teste (Phase 1)
├── contracts/           # Contratos de interface OpenAPI 3.1
│   └── openapi.yaml     # Especificação completa dos endpoints de gamificação e ranking
└── tasks.md             # Decomposição em tarefas executáveis (Phase 2 - speckit-tasks)
```

### Source Code (repository root)

```text
backend/
├── prisma/
│   ├── schema.prisma                        # Adição de UserGamificationProfile, GamificationTransaction e GamificationLevel
│   └── migrations/                          # Nova migração SQL versionada para tabelas de gamificação
├── src/
│   ├── modules/
│   │   ├── gamification/                    # Novo módulo completo de gamificação
│   │   │   ├── gamification.schemas.ts      # Schemas Zod de validação de queries e preferências
│   │   │   ├── gamification.service.ts      # Motor de pontos, idempotência, cálculo de ranking e estorno
│   │   │   └── gamification.routes.ts       # Endpoints Fastify (/api/v1/gamification/*)
│   │   ├── reviews/reviews.service.ts       # Gancho para acionar pontuação na publicação de avaliações
│   │   └── forum/forum.service.ts           # Gancho para acionar pontuação em tópicos e respostas úteis
│   └── server.ts                            # Registro do módulo gamificationRoutes
└── tests/
    ├── unit/
    │   └── gamification.service.test.ts     # Testes unitários de regras de pontuação, limites e estornos
    └── integration/
        └── gamification.routes.test.ts      # Testes de integração dos endpoints de ranking e preferências

frontend/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── gamification_profile.dart    # Entidade de perfil de gamificação e saldo
│   │   │   ├── leaderboard_entry.dart       # Entidade de item do ranking
│   │   │   ├── gamification_level.dart      # Entidade de nível hierárquico
│   │   │   └── gamification_transaction.dart# Entidade de transação do extrato
│   │   └── repositories/
│   │       └── gamification_repository.dart # Contrato abstrato do repositório
│   ├── data/
│   │   └── repositories/
│   │       └── gamification_repository_impl.dart # Implementação com Dio e tratamento de erros
│   └── presentation/
│       ├── bloc/
│       │   └── gamification/                # Gestão de estado BloC (leaderboard, perfil e extrato)
│       │       ├── gamification_bloc.dart
│       │       ├── gamification_event.dart
│       │       └── gamification_state.dart
│       ├── components/
│       │   ├── leaderboard_tile.dart        # Item da listagem de ranking com semântica acessível
│       │   ├── ranking_period_tabs.dart     # Abas acessíveis de período (Semanal, Mensal, Geral)
│       │   ├── user_rank_sticky_bar.dart    # Barra destacada com a posição do usuário
│       │   ├── level_badge_widget.dart      # Ícone e rótulo do nível com alto contraste
│       │   └── points_counter_banner.dart   # Notificação de pontuação ganha
│       └── views/
│           └── gamification/
│               ├── leaderboard_view.dart    # Tela principal do ranking de usuários
│               ├── gamification_profile_view.dart # Tela de perfil, níveis e extrato de pontos
│               └── gamification_privacy_view.dart # Tela de preferências de privacidade (LGPD)
```

**Structure Decision**: Padrão modular Full-Stack estabelecido no repositório DáPraIr?, com módulo backend desacoplado no Fastify e apresentação Flutter em Clean Architecture com BloC e componentes semânticos do Design System.

## Complexity Tracking

> Nenhuma violação aos princípios da Constituição foi identificada. O design atende com rigor à WCAG 2.1 AA, Clean Architecture, metas de cobertura >= 80%, LGPD e Docker.
