# Technical Research & Architecture Decisions: Painel de Controle Admin e Moderação

**Feature Branch**: `004-admin-moderation-panel`  
**Date**: 2026-11-05  
**Spec Reference**: [spec.md](./spec.md)  

Este documento consolida as pesquisas técnicas, decisões arquiteturais e trade-offs avaliados para viabilizar o **Painel de Controle Administrativo e Central de Moderação**, atendendo rigorosamente aos princípios constitucionais do DáPraIr? (WCAG 2.1 AA, Clean Architecture, Cobertura >= 80%, LGPD e Multiplataforma Flutter).

---

## 1. Controle de Acesso Baseado em Papéis (RBAC) e Invalidação Imediata de Sessões

### Decisão
Implementar um guard de autorização centralizado no backend Fastify (`requireAdminOrModerator` / `requireAdmin`) combinado com o campo `session_invalidated_at` na tabela `User`.
- Toda requisição em rotas protegidas valida se o usuário possui `role: 'ADMIN' | 'MODERATOR'`.
- O middleware de autenticação verifica adicionalmente se o timestamp de emissão do token JWT (`iat`) é anterior a `user.session_invalidated_at`. Caso seja, a requisição é sumariamente rejeitada com HTTP 401 Unauthorized e payload `{ code: 'SESSION_REVOKED', message: 'Sua sessão foi encerrada por alteração de status ou banimento.' }`.
- No cliente Flutter, um interceptor no cliente HTTP Dio captura a resposta 401 com código `SESSION_REVOKED`, limpa o token local seguro (`flutter_secure_storage`) e redireciona imediatamente para a tela de bloqueio/login informativo acessível.

### Racional
Atende diretamente ao critério de sucesso **SC-003** (invalidação em menos de 2 segundos de sessões e tokens de usuários suspensos ou banidos) sem a necessidade de um servidor de cache de tokens em memória complexo (Redis), mantendo a arquitetura simples e conteinerizada em PostgreSQL + Node.js.

### Alternativas Consideradas
- **Microserviço dedicado de autenticação / Auth0**: Rejeitado por adicionar sobrecarga operacional e violar o Princípio V da Constituição (paridade por contêineres simples Docker Compose).
- **Lista negra em memória (In-memory blacklist)**: Rejeitada pois não sincronizaria adequadamente caso a API Node.js fosse escalada em múltiplos contêineres/workers. O campo `session_invalidated_at` no PostgreSQL provê fonte única de verdade consistente.

---

## 2. Sistema Progressivo de Penalidades (Advertência, Suspensão 7 Dias, Banimento Permanente)

### Decisão
Criar a entidade `UserPenalty` com enumeração de tipos (`WARNING`, `SUSPENSION_7_DAYS`, `PERMANENT_BAN`) e status (`ACTIVE`, `EXPIRED`, `REVOKED`), com cálculo determinístico de expiração.
- **1ª Infração**: Criação de `UserPenalty` tipo `WARNING` com justificativa formal. A conta permanece ativa, mas uma notificação de advertência é exibida ao usuário no próximo acesso.
- **2ª Infração (Reincidência)**: Criação de `UserPenalty` tipo `SUSPENSION_7_DAYS`. O campo `ends_at` é fixado em `now() + 7 days`. O campo `status` do usuário na tabela `User` é atualizado para `SUSPENDED` e `session_invalidated_at` é atualizado para `now()`.
- **3ª Infração**: Criação de `UserPenalty` tipo `PERMANENT_BAN` (`ends_at = null`). O campo `status` do usuário é atualizado para `BANNED` e `session_invalidated_at = now()`.
- **Exceção de Gravidade Extrema**: Permite que administradores apliquem o `PERMANENT_BAN` imediatamente desde a primeira infração para casos severos (ex: crimes de ódio, assédio grave), mediante preenchimento obrigatório do campo `reason` (mínimo de 20 caracteres) e gravação imediata na trilha de auditoria.

### Racional
Satisfaz a decisão de esclarecimento do usuário (Opção 1-C), conferindo previsibilidade, transparência e respeito à governança comunitária, enquanto viabiliza atuação contundente em incidentes graves.

### Alternativas Consideradas
- **Banimento binário imediato simples (apenas booleano `is_banned`)**: Rejeitado pelo usuário (Opção 1-C) por não permitir gradação educativa de penalidades leves.

---

## 3. Moderação em Cascata de Tópicos e Conteúdos Unificados

### Decisão
Implementar um serviço centralizado de moderação polimórfica (`AdminModerationService`) executado dentro de transações atômicas Prisma (`prisma.$transaction`).
- Quando um `FORUM_TOPIC` for marcado como `HIDDEN_BY_ADMIN` ou `REMOVED_BY_ADMIN`:
  1. O status do tópico pai é alterado.
  2. Todas as respostas e subthreads filhas associadas (`ForumComment` onde `topic_id = target_id`) são atualizadas atomicamente para o status correspondente (`HIDDEN_BY_ADMIN` ou `REMOVED_BY_ADMIN`).
  3. É gerado um registro mestre de auditoria (`ModerationAction`) com indicador de impacto em cascata (`cascade_count: N`).
- No cliente público e consultas de fórum, as queries que já utilizam cláusulas `where: { status: 'ACTIVE' }` filtram automaticamente o tópico e todas as suas respostas, garantindo remoção visual instantânea (SC-004).
- Para outros tipos de conteúdo (`PLACE_REVIEW`, `PLACE_MEDIA`, `FORUM_COMMENT` avulso), a ação de ocultar ou remover atua sobre a entidade individualmente.

### Racional
Satisfaz a decisão de esclarecimento 2-A (cascata total) e 3-A (acervo unificado). Garante que nenhuma subthread fique órfã ou continue visível publicamente após a moderação do tópico mestre.

### Alternativas Consideradas
- **Soft-delete individual deixando comentários públicos**: Rejeitado pelo usuário (Opção 2-A) para evitar exibição de ramificações descontextualizadas de tópicos infringentes.

---

## 4. Trilha de Auditoria Imutável e Proteção de Dados (LGPD)

### Decisão
Modelar a tabela `moderation_actions` como um log de auditoria com gravação exclusiva (`INSERT` only; sem permissões de `UPDATE` ou `DELETE`).
- **Campos registrados**: `id`, `moderator_id`, `action_type`, `target_type`, `target_id`, `reason`, `metadata` (JSON contendo snapshot do item e detalhes contextuais), `ip_hash` e `created_at`.
- **Proteção do Denunciante (LGPD)**: Na interface do painel de moderação e na API de consulta de auditoria, os dados do denunciante são anonimizados/pseudonimizados (apenas identificador UUID e máscara de nome), preservando sua integridade contra retaliações.
- **Retenção Legal (Art. 16 da LGPD)**: Caso o usuário penalizado ou denunciante solicite exclusão cadastral por "direito ao esquecimento", o registro na tabela de usuários tem seus dados cadastrais pessoais apagados (nome, email, avatar, dados sensíveis de acessibilidade), mas os identificadores de auditoria em `moderation_actions` são preservados anonimizados para fins de comprovação legal e segurança jurídica.

### Racional
Garante conformidade integral com a Constituição DáPraIr? (Princípio IV - Privacidade e LGPD) e critério de sucesso **SC-002**.

---

## 5. Arquitetura da Interface Flutter e Acessibilidade (WCAG 2.1 AA)

### Decisão
Estruturar o módulo administrativo em Flutter na pasta `lib/presentation/views/admin/` e `lib/presentation/bloc/admin/`, projetado com design responsivo adaptável a telas desktop/web e dispositivos móveis.
- **Telas Principais**:
  1. `AdminDashboardView`: Visão geral com métricas de triagem (denúncias pendentes, ações do dia, usuários penalizados).
  2. `AdminReportsQueueView`: Fila de denúncias com filtros acessíveis por categoria e ordenação por criticidade.
  3. `AdminContentModerationView`: Busca e listagem unificada de conteúdos postados (tópicos, comentários, avaliações, fotos) com ações de "Ocultar", "Restaurar" e "Excluir".
  4. `AdminUserManagementView`: Listagem de usuários, ficha cadastral de infrações e aplicação de penalidades escalonadas.
  5. `AdminAuditLogsView`: Consulta paginada dos logs de auditoria imutáveis.
- **Acessibilidade Mandatória**:
  - Uso estrito de `Semantics` em botões de ação destrutiva, anunciando a gravidade ("Ação de moderação permanente: excluir conteúdo").
  - Modais de confirmação acessíveis com foco inicial gerenciado (`FocusNode`) e armadilha de foco para leitores de tela.
  - Alvos de clique >= 48x48 dp em todos os botões de ação rápida.
  - Taxa de contraste >= 4.5:1 nos badges de status (Pendente, Ocultado, Banido, Suspenso).

---

## Conclusão da Fase de Pesquisa
Todas as incertezas técnicas e funcionais foram sanadas. As tecnologias escolhidas alinham-se perfeitamente com a stack existente (Node.js + Fastify + Prisma + PostgreSQL + Flutter BLoC) sem adicionar débitos técnicos ou dependências externas dispensáveis.
