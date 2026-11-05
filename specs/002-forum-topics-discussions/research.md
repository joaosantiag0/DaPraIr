# Phase 0 Research: Espaço de Debate e Fórum de Tópicos Categorizados

**Feature Branch**: `002-forum-topics-discussions`  
**Date**: 2026-11-04  
**Status**: Completed  

---

## 1. Modelagem de Subthreads e Árvore Hierárquica de Respostas

### Contexto
O requisito FR-007 e a clarificação de 2026-11-04 exigem que comentários suportem subthreads encadeadas com aninhamento hierárquico até o 3º nível estrutural. Respostas adicionais além do 3º nível devem ser alinhadas visualmente ao 3º nível com citação/menção explícita (`@usuario`). Além disso, debates devem permitir recolher/expandir galhos (FR-009) e manter integridade após exclusões (FR-012, SC-005).

### Alternativas Consideradas
1. **Adjacency List Pura (parent_id auto-relacionado)**:
   - *Prós*: Modelagem nativa no Prisma (`parent Comment? @relation("ThreadReplies", fields: [parent_id], references: [id])`), criação atômica simples e sem complexidade de rebalanceamento.
   - *Contras*: Recuperação de árvores arbitrárias requer CTE recursivo (`WITH RECURSIVE`) ou carregamento de todos os comentários do tópico com reconstrução em memória.
2. **Materialized Path (ex: `1/4/9`)**:
   - *Prós*: Consultas por prefixo para sub-árvores inteiras.
   - *Contras*: Requer reescrita de caminhos caso nós sejam movidos; formatação frágil com UUIDs.
3. **PostgreSQL `ltree` extension**:
   - *Prós*: Alta performance para buscas hierárquicas complexas.
   - *Contras*: Dependência adicional no PostgreSQL e tipagem não nativa no Prisma Client.
4. **Adjacency List Enriquecida com `depth` e `root_comment_id`**:
   - *Prós*: Cada registro armazena `parent_id` (UUID), `depth` (inteiro: 1, 2 ou 3) e `reply_to_user_id` (para citações explícitas além do 3º nível). Consultas por tópico podem trazer a lista indexada por `created_at ASC`, e a árvore é montada no frontend/serviço em tempo O(N) com memória mínima.
   - *Contras*: Requer cálculo de `depth = min(parent.depth + 1, 3)` na criação.

### Decisão
**Adjacency List Enriquecida (`parent_id`, `depth`, `reply_to_user_id`)**:
- Tabela `forum_comments`:
  - `parent_id`: UUID opcional (nulo para comentários raiz de 1º nível).
  - `depth`: SmallInt (1 para raiz, 2 para réplica direta, 3 para réplica de 2º nível e subsequentes).
  - `reply_to_user_id`: UUID opcional apontando para o autor específico que foi respondido (preenchido obrigatoriamente quando `depth == 3` ou em réplicas diretas).
- A consulta recupera os comentários ativos do tópico com ordenação cronológica e projeta na estrutura de árvore hierárquica.

---

## 2. Controle de Visibilidade em Três Níveis e Limite do Tópico (Ceiling Rule)

### Contexto
Conforme FR-003, FR-004, FR-005, FR-008 e Assumptions da especificação:
- Três níveis de visibilidade: `PUBLIC`, `COMMUNITY`, `AUTHOR`.
- **Teto de Visibilidade (Ceiling Rule)**: O tópico define o alcance máximo permitido. Se um tópico for `COMMUNITY`, um comentário criado nele nunca poderá ser `PUBLIC` para visitantes anônimos.
- **Visitantes Anônimos**: Podem acessar apenas tópicos `PUBLIC` e comentários `PUBLIC` contidos neles.
- **Membros Autenticados**: Podem acessar tópicos e comentários `PUBLIC` e `COMMUNITY`.
- **Escopo `AUTHOR` (Só para o autor)**:
  - Para um tópico: Acessível exclusivamente pelo próprio autor do tópico (e administradores/moderadores).
  - Para um comentário: Acessível exclusivamente pelo autor do comentário **E** pelo autor do tópico principal (canal de diálogo contextual privado, conforme clarificação).

### Lógica de Filtragem no Banco (Backend Service)
Ao consultar tópicos ou comentários, a consulta aplica cláusulas `WHERE` baseadas na identidade do chamador:
```typescript
// Exemplo de predicado para tópicos
function buildTopicVisibilityFilter(currentUserId?: string) {
  if (!currentUserId) {
    // Visitante anônimo
    return { visibility: 'PUBLIC', status: 'ACTIVE' };
  }
  // Usuário autenticado
  return {
    status: 'ACTIVE',
    OR: [
      { visibility: { in: ['PUBLIC', 'COMMUNITY'] } },
      { visibility: 'AUTHOR', author_id: currentUserId },
    ],
  };
}

// Exemplo de predicado para comentários em um tópico (topicAuthorId, topicVisibility)
function buildCommentVisibilityFilter(topic: { id: string, author_id: string, visibility: string }, currentUserId?: string) {
  if (!currentUserId) {
    // Visitante anônimo só vê se tópico for público e comentário for público
    if (topic.visibility !== 'PUBLIC') return { id: 'none' };
    return { topic_id: topic.id, visibility: 'PUBLIC', status: { not: 'REMOVED_BY_ADMIN' } };
  }
  // Usuário autenticado
  return {
    topic_id: topic.id,
    status: { not: 'REMOVED_BY_ADMIN' },
    OR: [
      { visibility: { in: ['PUBLIC', 'COMMUNITY'] } },
      { visibility: 'AUTHOR', author_id: currentUserId },
      { visibility: 'AUTHOR', topic: { author_id: currentUserId } }, // Autor do tópico visualiza comentários privados
    ],
  };
}
```

### Racional
A filtragem direta no banco de dados impede vazamento de dados em memória e garante conformidade absoluta com os requisitos de privacidade e LGPD (PR-002, SC-002).

---

## 3. Gestão de Categorias e Autorização Administrativa

### Contexto
Conforme FR-001 e a sessão de clarificação:
- As categorias do fórum são gerenciadas exclusivamente por administradores (curadoria centralizada).
- Usuários comuns selecionam uma categoria ativa obrigatória ao criar tópicos.

### Decisão
- Tabela `forum_categories`:
  - `id`: UUID.
  - `name`: VarChar(100) único.
  - `slug`: VarChar(100) único para URLs semânticas.
  - `description`: Text amigável.
  - `icon_name`: VarChar(50) para renderização no Flutter.
  - `display_order`: Int para ordenação curada.
  - `is_active`: Boolean (default true).
  - `topics_count`: Int (default 0) atualizado via triggers/transações.
- Rotas:
  - `GET /api/v1/forum/categories`: Público (retorna categorias ativas).
  - `POST /api/v1/forum/categories`: Restrito a `role === 'ADMIN'`.
  - `PATCH /api/v1/forum/categories/:id`: Restrito a `role === 'ADMIN'`.
  - `DELETE /api/v1/forum/categories/:id`: Restrito a `role === 'ADMIN'` (soft-disable `is_active = false`).

---

## 4. Curtidas / Votos (Upvotes) e Contadores Desnormalizados

### Contexto
Conforme FR-015 e a sessão de clarificação:
- Curtida simples (upvote): 1 curtida por usuário por item (tópico ou comentário).
- Pode alternar (toggle like / unlike).
- Contadores públicos de curtidas para ordenação rápida ("mais curtidos").

### Decisão
- Tabelas dedicadas com integridade relacional:
  - `forum_topic_likes`: Chave única composta `@@unique([user_id, topic_id])`.
  - `forum_comment_likes`: Chave única composta `@@unique([user_id, comment_id])`.
- Os modelos `ForumTopic` e `ForumComment` mantêm as colunas desnormalizadas `likes_count Int @default(0)` e `comments_count Int @default(0)`.
- A alternância de voto (toggle) é executada em transação Prisma (`$transaction`):
  - Se registro existe: remove like e decrementa `likes_count` atomicamente (`decrement: 1`).
  - Se não existe: cria like e incrementa `likes_count` atomicamente (`increment: 1`).

---

## 5. Exclusão Segura, Soft-Delete e Preservação de Árvore (LGPD)

### Contexto
Conforme FR-010, FR-011, FR-012, PR-003 e SC-005:
- Quando o autor exclui um comentário que possui respostas filhas, o comentário não deve ser apagado fisicamente, para não quebrar as subthreads subordinadas nem sumir com as réplicas dos demais usuários.
- O conteúdo e a identificação do autor devem ser removidos e substituídos por "[Comentário removido pelo autor]".
- Caso um comentário não possua filhos, pode ser excluído fisicamente ou marcado como deletado.
- Edição de tópicos e comentários deve sinalizar visualmente `is_edited: true` e `edited_at: DateTime`.

### Decisão
- Colunas em `forum_comments`:
  - `status`: Enum ou VarChar (`ACTIVE`, `REMOVED_BY_AUTHOR`, `REMOVED_BY_ADMIN`).
  - `content`: Text (ao remover com filhos, substituído por `"[Comentário removido pelo autor]"`).
  - `is_edited`: Boolean (`default(false)`).
  - `edited_at`: DateTime opcional.
- Na exibição para o frontend:
  - Se `status === 'REMOVED_BY_AUTHOR'`, o backend não envia o perfil do autor (`author = null`), envia texto fixo seguro e desativa opções de like/responder sobre o nó removido, preservando seus nós filhos intactos.

---

## 6. Denúncias Comunitárias e Moderação Administrativa

### Contexto
Conforme FR-016, FR-017 e a sessão de clarificação:
- Usuários autenticados podem denunciar publicações impróprias com motivo pré-definido.
- Administradores analisam e podem moderar (manter, ocultar ou remover).

### Decisão
- O sistema já possui a tabela e modelo `ContentReport` em `prisma/schema.prisma` com `target_type: String` e `target_id: String`.
- Vamos reutilizar a infraestrutura existente de `ContentReport`, padronizando `target_type`:
  - `"FORUM_TOPIC"`
  - `"FORUM_COMMENT"`
- Motivos padronizados (`reason`): `SPAM`, `HARASSMENT`, `HATE_SPEECH`, `PRIVACY_VIOLATION`, `INAPPROPRIATE_CONTENT`, `OTHER`.
- Quando um moderador aprova uma denúncia e remove o conteúdo, o status do tópico ou comentário é atualizado para `REMOVED_BY_ADMIN`.

---

## 7. Acessibilidade na Apresentação das Subthreads (Flutter WCAG 2.1 AA)

### Contexto
Conforme AR-001 a AR-005:
- Leitores de tela (TalkBack e VoiceOver) devem anunciar explicitamente:
  - Título e autor da publicação.
  - Nível de aninhamento da subthread (ex: "Resposta nível 2 a @joao").
  - Estado de recolhido/expandido.
  - Nível de visibilidade (ex: "Visibilidade: Público" ou "Visibilidade: Comunidade").
- Alvos de toque >= 48x48 dp.
- Contraste de cores >= 4.5:1.
- Layout flexível que suporte fontes ampliadas em até 200% sem quebra horizontal.

### Decisão de Componentização Flutter
- `ForumCategoryCard`: Card com semântica de botão de categoria, anunciando nome e contagem de tópicos.
- `ForumTopicTile`: Item da lista de tópicos com badges acessíveis de categoria, visibilidade e contadores.
- `ForumCommentThreadWidget`: Componente recursivo/linearizado com recuo visual máximo de 3 níveis (`depth * 16.0 dp`).
  - Além do nível 3, o recuo permanece em 32 dp (nível 3) e exibe o chip semântico "Respondendo a @usuario".
  - Botão de colapsar/expandir com área mínima de 48x48 dp e `Semantics(expanded: isExpanded, label: "Recolher respostas de @usuario")`.
- `VisibilitySelector`: Seletor de rádio acessível com opções descritivas (`Público - Qualquer pessoa pode ver`, `Comunidade - Apenas membros cadastrados`, `Só para o autor - Apenas você e o autor`).

---

## 8. Conclusão da Pesquisa e Resoluções

Todos os tópicos técnicos e de governança foram avaliados e resolvidos de forma aderente à Constituição do projeto e aos padrões já estabelecidos na Feature 001. Nenhuma pendência técnica ("NEEDS CLARIFICATION") permanece em aberto.
