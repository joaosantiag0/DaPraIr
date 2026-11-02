# Arquitetura e Engenharia do Sistema — DáPraIr?

O **DáPraIr?** é uma plataforma comunitária colaborativa focada em acessibilidade física para pessoas com deficiência motora, mobilidade reduzida, idosos e acompanhantes.

---

## 1. Visão Geral da Arquitetura

O sistema adota uma arquitetura em duas camadas principais:
1. **Frontend Multiplataforma**: Desenvolvido em Flutter 3 (Android, iOS, Web), orientado a Clean Architecture com BLoC para gerenciamento de estado e Drift para persistência offline First.
2. **Backend Escalável**: Desenvolvido em Node.js com Fastify e TypeScript, utilizando Prisma ORM com PostgreSQL 16 e extensões PostGIS para consultas geoespaciais (`ST_DistanceSphere`).

```
+-------------------------------------------------------------+
|                  Flutter Multiplataforma                    |
|  (WCAG 2.1 AA/AAA - BLoC - Drift SQLite Offline Cache)      |
+-------------------------------------------------------------+
                              |
                     HTTPS / WSS (JSON)
                              |
+-------------------------------------------------------------+
|                 Fastify TypeScript API                      |
|  - Auth & LGPD Crypto (Argon2id, AES-256-GCM)               |
|  - Swagger OpenAPI Documentation (/docs)                    |
|  - WebSocket Direct Messaging (Chat 1:1)                    |
|  - Spatial Queries Engine (PostGIS)                         |
|  - Content Moderation & Quarantine Threshold                |
+-------------------------------------------------------------+
                              |
+-------------------------------------------------------------+
|               PostgreSQL 16 + PostGIS                       |
|  - places (spatial points, reviews, media)                  |
|  - users, profiles, encrypted consents                      |
|  - social_connections & direct_messages                     |
|  - events & rsvps                                           |
|  - content_reports                                          |
+-------------------------------------------------------------+
```

---

## 2. Pilares Constitucionais Implementados

### I. Acessibilidade Universal como Cidadã de Primeira Classe (WCAG 2.1 AA / AAA)
- **Alvos de Toque**: Componentes reutilizáveis garantem dimensões mínimas de 48x48 dp (`AccessibleButton`, `AccessibleTextField`, `FilterChip`).
- **Audiodescrição Obrigatória**: Nenhuma foto pode ser submetida sem `alt_text` descritivo detalhado (validado no frontend e backend).
- **Semântica para Leitores de Tela**: Todos os cards e botões possuem rótulos semânticos completos anunciando contexto e status.
- **Tema de Alto Contraste**: Contraste superior a 7:1 em textos e ícones no modo de alto contraste.

### II. Multiplataforma e Responsividade
- Interface Flutter adaptável para dispositivos móveis e navegadores web.
- Integração nativa com apps de navegação externa (Google Maps, Waze, Apple Maps).

### III. Privacidade Rigorosa e Conformidade LGPD
- **Criptografia AES-256-GCM**: Condições de saúde e preferências de acessibilidade são criptografadas em repouso.
- **Argon2id**: Hash seguro para senhas de usuários.
- **Pseudonimização**: Endereços IP de consentimento são hasheados com SHA-256 e salteados.
- **Direitos do Titular**: Endpoints para Portabilidade de Dados (`/users/me/export-data`) e Direito ao Esquecimento (`/users/me/anonymize`).

### IV. Segurança Comunitária e Barreira no Chat 1:1
- Mensagens diretas entre usuários são permitidas **apenas** entre conexões aceitas no estado `ACCEPTED`.
- Bloqueio mútuo encerra imediatamente o canal de comunicação em tempo real.

### V. Qualidade com Cobertura Automatizada >= 80%
- Mais de 70 testes automatizados cobrindo fluxos críticos de ponta a ponta.
- Testes unitários de criptografia, integração de rotas e testes de widgets/acessibilidade.

---

## 3. Módulos e Endpoints da API

| Módulo | Prefixo | Descrição |
|---|---|---|
| **Auth** | `/api/v1/auth` | Registro com consentimento LGPD, login e renovação de JWT |
| **Places** | `/api/v1/places` | Busca espacial PostGIS, listagem e criação de locais |
| **Reviews** | `/api/v1/places/:id/reviews` | Avaliações nos 7 critérios padronizados de acessibilidade |
| **Media** | `/api/v1/places/:id/media` | Upload otimizado via Sharp com validação estrita de alt_text |
| **Users & LGPD** | `/api/v1/users` | Perfis com visibilidade granular, exportação e anonimização |
| **Social** | `/api/v1/social` | Recomendações por afinidade e máquina de estados de amizade |
| **Chat 1:1** | `/api/v1/chat` | Histórico REST e WebSocket tempo real restrito a amigos |
| **Events** | `/api/v1/events` | Encontros inclusivos com checklist obrigatório e RSVP |
| **Feed** | `/api/v1/feed` | Feed comunitário agregado (locais, avaliações, eventos, dicas) |
| **Reports** | `/api/v1/reports` | Denúncias com quarentena automática por limiar de relatores |

---

## 4. Máquina de Estados da Moderação (Quarentena Automática)

```
[CONTEÚDO PUBLICADO]
         |
         |---> 1 ou 2 denúncias distintas
         |     Status: UNDER_REVIEW (Permanece público com selo de alerta)
         |
         |---> >= 3 denúncias distintas
         |     Status: QUARANTINED (Auto-ocultado de feeds e consultas públicas)
         |
    [MODERAÇÃO HUMANA]
         |
         |---> RESOLVE_RESTORE  --> Status: PUBLISHED
         |---> RESOLVE_REMOVE   --> Status: REMOVED
         |---> DISMISS          --> Status: PUBLISHED
```
