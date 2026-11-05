# Data Model: Espaço de Debate e Fórum de Tópicos Categorizados

**Feature Branch**: `002-forum-topics-discussions`  
**Date**: 2026-11-04  
**Status**: Complete  

---

## 1. Visão Geral do Modelo de Dados

O modelo de dados do fórum implementa um sistema de discussão estruturado e categorizado, com suporte a visibilidade granular em 3 níveis (`PUBLIC`, `COMMUNITY`, `AUTHOR`), árvores de subthreads hierárquicas com até 3 níveis de profundidade, curtidas (upvotes), moderação comunitária e integridade de histórico de debates em conformidade com a LGPD.

```
+--------------------+       1:N       +---------------------+
|   forum_categories |<----------------|     forum_topics    |
+--------------------+                 +---------------------+
                                                  | 1:N
                                                  |
                                                  v
                                       +---------------------+
                                       |    forum_comments   |
                                       +---------------------+
                                        | parent_id (auto-ref)
                                        v
                                       +---------------------+
                                       |    forum_comments   |
                                       +---------------------+
```

---

## 2. Tabelas e Entidades do Banco de Dados (PostgreSQL + Prisma)

### 2.1. `forum_categories` (Categorias Temáticas do Fórum)

Gerenciadas exclusivamente por administradores da plataforma.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK, default `gen_random_uuid()` | Identificador único da categoria |
| `name` | VarChar(100) | NOT NULL, UNIQUE | Nome de exibição da categoria (ex: "Mobilidade Urbana") |
| `slug` | VarChar(100) | NOT NULL, UNIQUE | Identificador amigável para URLs e filtros |
| `description` | Text | NOT NULL | Descrição temática e orientações para os tópicos |
| `icon_name` | VarChar(50) | NOT NULL | Nome do ícone Material/Cupertino para a UI |
| `display_order` | Int | NOT NULL, default `0` | Ordem de exibição na listagem |
| `is_active` | Boolean | NOT NULL, default `true` | Indica se a categoria aceita novos tópicos |
| `topics_count` | Int | NOT NULL, default `0` | Total de tópicos ativos na categoria |
| `created_at` | Timestamptz | NOT NULL, default `now()` | Data de criação |
| `updated_at` | Timestamptz | NOT NULL, default `now()` | Data da última atualização |

**Índices**:
- `@@index([is_active, display_order])`
- `@@unique([slug])`

---

### 2.2. `forum_topics` (Tópicos Principais de Discussão)

Representa os tópicos abertos por usuários dentro de uma categoria.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK, default `gen_random_uuid()` | Identificador único do tópico |
| `category_id` | UUID | FK -> `forum_categories.id` (RESTRICT) | Categoria temática obrigatória |
| `author_id` | UUID | FK -> `users.id` (CASCADE) | Usuário autor do tópico |
| `title` | VarChar(200) | NOT NULL | Título do debate (mínimo 5, máximo 200 caracteres) |
| `content` | Text | NOT NULL | Corpo do texto e argumentação inicial (mínimo 10 carac.) |
| `visibility` | VarChar(20) | NOT NULL, default `'PUBLIC'` | `PUBLIC`, `COMMUNITY`, `AUTHOR` |
| `status` | VarChar(20) | NOT NULL, default `'ACTIVE'` | `ACTIVE`, `LOCKED`, `REMOVED_BY_AUTHOR`, `REMOVED_BY_ADMIN` |
| `is_edited` | Boolean | NOT NULL, default `false` | Indica se o texto original foi editado |
| `edited_at` | Timestamptz | NULL | Data da última alteração de conteúdo |
| `likes_count` | Int | NOT NULL, default `0` | Total de curtidas recebidas |
| `comments_count` | Int | NOT NULL, default `0` | Total de comentários e réplicas ativas |
| `created_at` | Timestamptz | NOT NULL, default `now()` | Data/hora de publicação |
| `updated_at` | Timestamptz | NOT NULL, default `now()` | Data da última atividade/atualização |

**Índices**:
- `@@index([category_id, status, created_at(sort: Desc)])`
- `@@index([author_id, status])`
- `@@index([visibility, status])`
- `@@index([likes_count(sort: Desc)])`

---

### 2.3. `forum_comments` (Comentários e Respostas Aninhadas em Subthread)

Representa manifestações de primeiro nível ou réplicas hierárquicas.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK, default `gen_random_uuid()` | Identificador único do comentário |
| `topic_id` | UUID | FK -> `forum_topics.id` (CASCADE) | Tópico ao qual o comentário pertence |
| `parent_id` | UUID | FK -> `forum_comments.id` (CASCADE), NULL | Comentário pai (nulo se comentário raiz) |
| `author_id` | UUID | FK -> `users.id` (CASCADE) | Autor do comentário |
| `reply_to_user_id` | UUID | FK -> `users.id` (SET NULL), NULL | Usuário alvo de citação/resposta direta |
| `content` | Text | NOT NULL | Texto do comentário (máximo 5.000 caracteres) |
| `depth` | SmallInt | NOT NULL, default `1` | Nível estrutural: 1 (raiz), 2 (réplica), 3 (subthread) |
| `visibility` | VarChar(20) | NOT NULL, default `'PUBLIC'` | `PUBLIC`, `COMMUNITY`, `AUTHOR` |
| `status` | VarChar(20) | NOT NULL, default `'ACTIVE'` | `ACTIVE`, `REMOVED_BY_AUTHOR`, `REMOVED_BY_ADMIN` |
| `is_edited` | Boolean | NOT NULL, default `false` | Indica se o texto foi editado |
| `edited_at` | Timestamptz | NULL | Data da edição |
| `likes_count` | Int | NOT NULL, default `0` | Total de curtidas recebidas |
| `created_at` | Timestamptz | NOT NULL, default `now()` | Data/hora de envio |
| `updated_at` | Timestamptz | NOT NULL, default `now()` | Data de atualização |

**Índices**:
- `@@index([topic_id, created_at(sort: Asc)])`
- `@@index([parent_id])`
- `@@index([author_id])`

---

### 2.4. `forum_topic_likes` (Curtidas em Tópicos)

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK, default `gen_random_uuid()` | Identificador do like |
| `topic_id` | UUID | FK -> `forum_topics.id` (CASCADE) | Tópico curtido |
| `user_id` | UUID | FK -> `users.id` (CASCADE) | Usuário que curtiu |
| `created_at` | Timestamptz | NOT NULL, default `now()` | Data do voto |

**Índices e Restrições**:
- `@@unique([user_id, topic_id])`
- `@@index([topic_id])`

---

### 2.5. `forum_comment_likes` (Curtidas em Comentários)

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK, default `gen_random_uuid()` | Identificador do like |
| `comment_id` | UUID | FK -> `forum_comments.id` (CASCADE) | Comentário curtido |
| `user_id` | UUID | FK -> `users.id` (CASCADE) | Usuário que curtiu |
| `created_at` | Timestamptz | NOT NULL, default `now()` | Data do voto |

**Índices e Restrições**:
- `@@unique([user_id, comment_id])`
- `@@index([comment_id])`

---

## 3. Integração com Entidades Existentes

### 3.1. `users` (Usuários)
- Relações inversas:
  - `forum_topics ForumTopic[]`
  - `forum_comments ForumComment[]`
  - `forum_topic_likes ForumTopicLike[]`
  - `forum_comment_likes ForumCommentLike[]`

### 3.2. `content_reports` (Denúncias Comunitárias de Conteúdo)
A tabela já existente em `schema.prisma` é reutilizada:
- `target_type`: `"FORUM_TOPIC"` ou `"FORUM_COMMENT"`.
- `target_id`: ID do tópico ou comentário denunciado.
- `reason`: `"SPAM"`, `"HARASSMENT"`, `"HATE_SPEECH"`, `"PRIVACY_VIOLATION"`, `"INAPPROPRIATE_CONTENT"`, `"OTHER"`.
- `details`: Justificativa opcional fornecida pelo usuário.

---

## 4. Regras de Validação e Transição de Estado

### 4.1. Regras de Visibilidade (Ceiling Rule)
1. **Validação de Inserção de Comentário**:
   - `comment.visibility` não pode ser mais permissivo que `topic.visibility`.
   - Se `topic.visibility == 'COMMUNITY'`, então `comment.visibility` só pode ser `'COMMUNITY'` ou `'AUTHOR'`.
   - Se `topic.visibility == 'AUTHOR'`, então `comment.visibility` só pode ser `'AUTHOR'`.
   - Se `topic.visibility == 'PUBLIC'`, `comment.visibility` pode ser qualquer um dos três (`'PUBLIC'`, `'COMMUNITY'`, `'AUTHOR'`).

### 4.2. Regras de Profundidade de Subthreads (Max Depth 3)
1. Comentário sem `parent_id`:
   - `depth = 1`
   - `reply_to_user_id = null`
2. Comentário com `parent_id`:
   - Se `parent.depth == 1` -> `depth = 2`, `reply_to_user_id = parent.author_id`
   - Se `parent.depth == 2` -> `depth = 3`, `reply_to_user_id = parent.author_id`
   - Se `parent.depth >= 3` -> `depth = 3`, `reply_to_user_id = parent.author_id` (permanece no nível 3 com indicação explícita `@usuario`)

### 4.3. Ciclo de Vida e Soft-Delete (LGPD)
- **Remoção de Tópico**:
  - Se `comments_count == 0`: Pode ser removido fisicamente ou marcado como `REMOVED_BY_AUTHOR`.
  - Se `comments_count > 0`: `status = 'REMOVED_BY_AUTHOR'`, `title = "[Tópico removido pelo autor]"`, `content = "[Conteúdo removido pelo autor]"`.
- **Remoção de Comentário**:
  - Se possuir nós filhos ativos: `status = 'REMOVED_BY_AUTHOR'`, `content = "[Comentário removido pelo autor]"`. O vínculo visual de autoria é ocultado (`author_id` mantido apenas para integridade interna ou sanitizado).
  - Se não possuir nós filhos: Remoção física ou marcação como `REMOVED_BY_AUTHOR`.
