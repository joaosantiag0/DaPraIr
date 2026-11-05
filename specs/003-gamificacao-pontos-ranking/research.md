# Technical Research: Sistema de Gamificação (Pontuação e Ranking)

**Feature**: `003-gamificacao-pontos-ranking`  
**Date**: 2026-11-05  
**Spec Reference**: [spec.md](./spec.md)

---

## 1. Engine de Pontuação e Idempotência de Transações

### Decision
Implementar um serviço centralizado de gamificação (`GamificationService`) com transações atômicas no PostgreSQL via Prisma ORM (`prisma.$transaction`). Cada ação pontuável gera um registro imutável em `gamification_transactions` com uma chave de unicidade baseada em `(user_id, action_type, source_id)` para impedir duplicação acidental de pontos (idempotência). O saldo consolidado do usuário é mantido e atualizado atomicamente na tabela `user_gamification_profiles`.

### Rationale
- Operações de pontuação ocorrem em paralelo com ações de criação de conteúdo (avaliação de local, foto, post no fórum). Usar transações no banco de dados com chave única previne condições de corrida e ataques de repetição rápida (*double-spend/double-credit*).
- O saldo consolidado em `user_gamification_profiles` desacopla a leitura rápida de rankings da necessidade de calcular a soma de milhares de linhas históricas na tabela de transações a cada requisição.

### Alternatives Considered
- *Event-driven via Message Queue (RabbitMQ/Kafka)*: Excessivo para o escopo atual do MVP; adicionaria dependência de infraestrutura externa enquanto o Fastify + PostgreSQL em Docker resolve perfeitamente com latência sub-10ms.
- *Cálculo em tempo de execução via `SUM()`*: Inviável para escalabilidade, pois a consulta de ranking e extrato degradaria conforme o volume de avaliações aumentasse.

---

## 2. Cálculo e Atualização de Leaderboard Multi-Período (Semanal, Mensal, Geral)

### Decision
- **Ranking Geral**: Derivado diretamente de `user_gamification_profiles.points_total` ordenado de forma decrescente com índice B-tree em `(is_ranking_visible, points_total DESC)`.
- **Ranking Semanal e Mensal**: Calculado dinamicamente através de agregação filtrada por data na tabela `gamification_transactions` (`created_at >= start_of_period`) para usuários com `is_ranking_visible = true`, aproveitando um índice composto em `(created_at, user_id, points)`. Para otimização de leitura rápida na tela inicial, um cache em memória com TTL de 60 segundos ou consulta com CTE paginada atende os objetivos de resposta < 150ms.

### Rationale
- Manter o cálculo temporal baseado nas transações com data precisa evita desvios entre fuso horário e simplifica o estorno (se uma avaliação for cancelada, o débito correspondente afeta tanto o geral quanto o saldo do período).
- A política de privacidade (opt-out / ocultação do ranking público) é filtrada diretamente na query SQL através de `is_ranking_visible = true`.

### Alternatives Considered
- *Tabelas de snapshots com cron job*: Adicionaria atraso na exibição (dados não imediatos). A agregação direta com cache curto oferece consistência imediata para o próprio usuário e latência desprezível no volume esperado do MVP.
- *Redis Sorted Sets (ZADD/ZREVRANK)*: Excelente para milhões de usuários diários, mas adicionaria outro serviço ao Docker Compose. O PostgreSQL 16 com índices adequados atende facilmente os requisitos de desempenho (SC-002: < 1.5s).

---

## 3. Conformidade com a LGPD e Princípio de Minimização de Dados

### Decision
1. **Minimização**: O endpoint público do ranking expõe unicamente:
   - Identificador público ou pseudônimo (`display_name`, `avatar_url`, `handle`);
   - Total de pontos do período (`points`);
   - Posição ordinal (`rank`);
   - Nível hierárquico atual e insígnias públicas conquistadas (`level_name`, `badge_icon`).
   Nenhum dado pessoal sensível (tipo de deficiência, laudos, localização precisa) é trafegado ou associado ao ranking.
2. **Controle de Privacidade**: O usuário tem controle granular em seu perfil:
   - `is_ranking_visible`: booleano que permite sair totalmente da visualização pública (opt-out);
   - `use_anonymous_nickname`: booleano que substitui seu nome público por um pseudônimo comunitário gerado ou customizado (ex: "Explorador Anônimo #42").
3. **Direito ao Esquecimento / Exclusão**: Quando a conta do usuário for excluída (`users.status = 'DELETED'`), um gatilho de cascata ou serviço de exclusão anonimiza ou expurga seu perfil de gamificação, removendo-o imediatamente de todas as visões de leaderboard.

### Rationale
Atende com rigor ao Princípio IV da Constituição do DáPraIr? e à Lei nº 13.709/2018 (LGPD), assegurando que o engajamento comunitário não comprometa a privacidade dos usuários com deficiência.

---

## 4. Acessibilidade Universal no Flutter (WCAG 2.1 AA)

### Decision
- Uso de componentes semânticos (`Semantics`, `MergeSemantics`) para estruturar cada linha do ranking:
  - Anúncio sonoro ordenado: *"1º colocado, [Nome/Apelido], [Pontos] pontos, Nível [Nome do Nível]"*.
  - Alvos de toque de botões e abas temporais (Semanal, Mensal, Geral) com dimensão mínima de 48x48 dp.
  - Não dependência de cor: as posições 1º, 2º e 3º usam ícones distintos e numerais ordinais textuais explícitos ("1º", "2º", "3º"), e não apenas cores dourada/prateada/bronze.
  - Suporte completo a Alto Contraste e Dynamic Type (escalabilidade de fonte sem overflow).

### Rationale
Garante cumprimento irrestrito do Princípio I da Constituição, evitando qualquer barreira para usuários que utilizam TalkBack ou VoiceOver.
