# Feature Specification: Painel de Controle Administrativo e Central de Moderação

**Feature Branch**: `004-admin-moderation-panel`  
**Created**: 2026-11-05  
**Status**: Ready for Planning  
**Input**: User description: "precisamos de um painel de controle admin onde tenhamos acesso a tudo que foi postado, com opções de ocutar e excluir conteúdo, banir usuarios e ver as denúncias"

## Clarifications

### Session 2026-11-05
- Q: Qual deve ser o modelo de punição/banimento adotado pelo painel? → A: Sistema de escalonamento progressivo de advertências (1ª Advertência formal → 2ª Suspensão temporária de 7 dias com invalidação de sessão → 3ª Banimento permanente definitivo; com permissão de banimento permanente direto para infrações gravíssimas justificadas).
- Q: Como as subthreads e comentários vinculados a um tópico principal devem se comportar quando o tópico é moderado? → A: Ocultação/Exclusão em cascata total (ao ocultar ou excluir o tópico pai, todas as mensagens e subthreads filhas deixam a circulação pública imediatamente junto com o tópico, permanecendo acessíveis para auditoria no painel admin).
- Q: Quais tipos de publicações da plataforma devem ser gerenciados e moderados por este painel? → A: Conteúdo Unificado Total (Fórum de discussões/tópicos, Comentários/subthreads, Avaliações/Reviews de Acessibilidade de locais e Fotos/Mídias anexadas por usuários).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Triagem e Tratamento da Fila de Denúncias (Priority: P1)

Como um administrador ou moderador da plataforma, desejo acessar uma central unificada de denúncias recebidas da comunidade com detalhes do conteúdo reportado e motivo da infração, para que eu possa deliberar e tomar ações rápidas (aceitar aplicando sanção ou descartar como improcedente).

**Why this priority**: É a porta de entrada reativa mais crítica para manter a segurança, respeito e qualidade das informações da comunidade DáPraIr?, permitindo agir diretamente sobre abusos reportados pelos próprios usuários.

**Independent Test**: Pode ser testado de ponta a ponta simulando uma denúncia enviada por um usuário sobre uma postagem, autenticando como administrador, visualizando a denúncia na fila com contador pendente, abrindo os detalhes e executando a resolução (aceitar ou rejeitar denúncia), verificando a atualização imediata do status da fila.

**Acceptance Scenarios**:

1. **Given** um administrador autenticado acessando o painel de moderação, **When** abre a aba "Fila de Denúncias", **Then** visualiza a listagem de denúncias pendentes ordenadas por gravidade e data, contendo tipo de item denunciado, motivo alegado, identificador do denunciante e tempo de espera.
2. **Given** uma denúncia pendente selecionada, **When** o administrador clica para inspecionar, **Then** o sistema exibe o conteúdo denunciado em seu contexto original (postagem, autor, data, denúncias anteriores do mesmo item).
3. **Given** uma denúncia sob análise, **When** o administrador determina que não houve infração às diretrizes e clica em "Rejeitar Denúncia" com justificativa, **Then** a denúncia é arquivada como improcedente, o conteúdo permanece ativo e o registro de auditoria é gravado.
4. **Given** uma denúncia procedente, **When** o administrador clica em "Aceitar Denúncia", **Then** o sistema apresenta atalhos diretos para aplicar moderação imediata sobre o conteúdo (ocultar ou excluir) e/ou sobre o autor (advertir, suspender ou banir).

---

### User Story 2 - Gestão e Moderação de Conteúdos Postados (Priority: P2)

Como um administrador, desejo pesquisar, filtrar e visualizar todo o acervo unificado de conteúdos postados no sistema (tópicos, comentários, avaliações de acessibilidade de locais e fotos), com capacidade de ocultar preventivamente ou excluir em definitivo publicações que violem diretrizes, para assegurar a conformidade e a integridade da plataforma.

**Why this priority**: Complementa a triagem de denúncias ao permitir moderação proativa e busca detalhada em todo o ecossistema de publicações da plataforma, garantindo que conteúdos impróprios ou desinformativos possam ser neutralizados imediatamente.

**Independent Test**: Pode ser testado buscando uma postagem específica através de filtros no painel admin, acionando a opção de "Ocultar", conferindo que ela desaparece do feed público dos usuários normais mantendo registro no painel, e em seguida testando a opção de "Excluir" com confirmação explícita.

**Acceptance Scenarios**:

1. **Given** um administrador no módulo "Conteúdos Postados", **When** aplica filtros por tipo de conteúdo (tópicos, comentários, avaliações, fotos), período de postagem, status (ativo/oculto/excluído) ou termo de busca textual, **Then** o sistema retorna a lista paginada dos itens correspondentes com informações de autoria e contadores de engajamento.
2. **Given** um item com status ativo publicado, **When** o administrador aciona a ação "Ocultar Conteúdo" e insere a justificativa obrigatória, **Then** o item se torna imediatamente inacessível para usuários regulares e visitantes, permanecendo visível no painel administrativo com indicador de "Ocultado pela Moderação".
3. **Given** um item previamente ocultado, **When** o administrador revisa e constata regularidade ou correção, acionando "Restaurar Conteúdo", **Then** a publicação volta a ficar visível publicamente em sua respectiva listagem.
4. **Given** um conteúdo com infração grave ou solicitação irremediável, **When** o administrador aciona "Excluir Conteúdo", confirma o modal de segurança e fornece o motivo, **Then** o conteúdo é despublicado de forma irreversível ou marcado como removido, aplicando cascata quando se tratar de tópico pai e registrando o log na trilha de auditoria.

---

### User Story 3 - Gestão de Usuários, Aplicação de Sanções e Banimento (Priority: P3)

Como um administrador, desejo consultar perfis de usuários cadastrados, visualizar histórico de infrações/denúncias acumuladas e aplicar advertências, suspensões temporárias de 7 dias ou banimento permanente, para proteger a comunidade contra comportamentos abusivos, spam e reincidências.

**Why this priority**: A moderação de conteúdo individual é ineficaz se contas infratoras continuarem operando livremente; o controle de contas e sanções escalonadas remove atores maliciosos da plataforma de forma justa e transparente.

**Independent Test**: Pode ser testado localizando um usuário infrator no painel, aplicando o banimento com registro de motivo, tentando autenticar ou realizar publicações com a conta banida e confirmando que o sistema bloqueia as operações informando a suspensão de forma clara.

**Acceptance Scenarios**:

1. **Given** um administrador na seção "Gerenciamento de Usuários", **When** busca um usuário por nome ou identificador, **Then** visualiza a ficha de perfil com data de cadastro, total de publicações, histórico de infrações/denúncias recebidas e status atual da conta (Ativo, Advertido, Suspenso ou Banido).
2. **Given** um usuário com infrações confirmadas, **When** o administrador aciona "Aplicar Sanção / Banir", seleciona o nível do escalonamento (Advertência, Suspensão de 7 dias ou Banimento Definitivo) e preenche a justificativa obrigatória, **Then** a penalidade é ativada e, nos casos de suspensão ou banimento, as credenciais e sessões ativas são invalidadas imediatamente.
3. **Given** um usuário suspenso ou banido tentando fazer login ou realizar ações protegidas na plataforma, **When** tenta submeter uma requisição, **Then** o sistema impede a ação e exibe mensagem informativa acessível comunicando o bloqueio, prazo restante (se suspensão temporária) e canal para contato/suporte.
4. **Given** um usuário com status de suspenso ou banido, **When** um administrador com permissão revisa a penalidade e clica em "Revogar Penalidade / Reativar Conta", **Then** o status do usuário retorna a "Ativo" com registro justificado na trilha de auditoria.

---

### User Story 4 - Trilha de Auditoria e Governança de Moderação (Priority: P4)

Como um administrador ou auditor do sistema, desejo consultar um registro imutável de todas as ações de moderação executadas (quem moderou, qual ação realizou, justificativa e carimbo de data/hora), para garantir transparência, prestação de contas interna e conformidade jurídica/LGPD.

**Why this priority**: Essencial para governança institucional, prevenção de abusos de poder por moderadores individuais e respaldo jurídico em caso de disputas ou notificações formais.

**Independent Test**: Pode ser testado executando uma ação de moderação (ocultar, excluir ou banir) e verificando em seguida na tela de "Logs de Auditoria" se o evento foi gravado com dados precisos de autor da moderação, alvo, timestamp e motivo, sem exposição desnecessária de dados sensíveis.

**Acceptance Scenarios**:

1. **Given** qualquer ação moderadora realizada no painel (ocultação, exclusão, banimento ou encerramento de denúncia), **When** o comando é concluído com sucesso, **Then** o sistema gera automaticamente um registro de log imutável contendo ID do moderador, tipo de ação, ID do recurso alvo, motivo informado e timestamp.
2. **Given** um administrador acessando a tela "Trilha de Auditoria", **When** filtra por período, administrador responsável ou tipo de ação, **Then** o sistema lista cronologicamente os eventos de moderação de maneira paginada e acessível.

---

### Edge Cases

- **Moderação em Cascata de Tópicos com Respostas**: Se um tópico pai for ocultado ou excluído pela moderação, todas as respostas e subthreads filhas associadas saem imediatamente de circulação pública em conjunto (cascata total), permanecendo acessíveis e íntegras exclusivamente no painel administrativo para análise e auditoria.
- **Tentativa de Ação por Administrador sobre Outro Administrador**: Um administrador ou moderador comum não pode banir nem excluir conteúdos postados por outros administradores sem privilégios de superadministrador (SuperAdmin).
- **Tentativa de Autenticação com Token/Sessão Ativa no Momento do Banimento**: Se o usuário estiver navegando ativamente com token de sessão aberto quando for banido no painel admin, sua próxima requisição à API é sumariamente rejeitada (401/403 com payload indicando status banido), deslogando a aplicação cliente imediatamente.
- **Denúncias Simultâneas Múltiplas sobre o Mesmo Conteúdo**: Se dezenas de usuários denunciarem o mesmo post em curto intervalo, o sistema agrupa as denúncias sob o mesmo item alvo em vez de fragmentar a fila em dezenas de itens separados, exibindo um contador cumulativo de relevância (ex: "15 denúncias").
- **Solicitação LGPD de Exclusão de Conta Concorrente com Investigação/Banimento**: Se um usuário denunciado ou banido solicitar exclusão de conta via LGPD ("direito ao esquecimento"), o sistema anonimiza dados cadastrais pessoais mas preserva os identificadores técnicos e logs de auditoria necessários para cumprimento de obrigação legal e prevenção a fraudes (Art. 16, I da LGPD).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema DEVE restringir o acesso a todas as rotas e interfaces do painel de moderação exclusivamente a usuários com papel de Administrador ou Moderador autenticados (RBAC).
- **FR-002**: O sistema DEVE fornecer um painel com visão consolidada das denúncias pendentes, permitindo filtrar por data, categoria da denúncia e gravidade.
- **FR-003**: O sistema DEVE permitir a inspeção contextual de cada denúncia, apresentando o texto original, anexos, dados do denunciante, justificativa do reporte e histórico prévio de infrações.
- **FR-004**: O sistema DEVE disponibilizar ação de "Rejeitar Denúncia" (marcar como improcedente) e "Aceitar Denúncia", exigindo preenchimento de justificativa textual.
- **FR-005**: O sistema DEVE disponibilizar listagem paginada e centralizada de todos os conteúdos postados na plataforma, englobando Fórum/Debates (tópicos e respostas), Avaliações/Reviews de Acessibilidade de Locais e Fotos/Mídias anexadas, com filtros por tipo, data, status de moderação e autor.
- **FR-006**: O sistema DEVE disponibilizar a ação de "Ocultar Conteúdo", tornando a publicação imediatamente invisível em consultas públicas e listagens comunitárias, com possibilidade de restauração futura pelo administrador.
- **FR-007**: O sistema DEVE disponibilizar a ação de "Excluir Conteúdo", exigindo dupla confirmação de segurança e justificativa formal do administrador, aplicando exclusão em cascata das respostas subordinadas quando o nó excluído for um tópico principal.
- **FR-008**: O sistema DEVE permitir a busca e listagem de usuários com informações de status cadastral, data de ingresso e total de infrações registradas.
- **FR-009**: O sistema DEVE fornecer a funcionalidade de penalização e banimento de usuários baseada em modelo de escalonamento progressivo (1ª infração: Advertência formal registrada; 2ª infração/reincidência: Suspensão temporária de 7 dias com encerramento forçado de sessão; 3ª infração: Banimento permanente definitivo), permitindo também ao administrador aplicar o banimento definitivo imediato em caso de violação gravíssima com justificativa obrigatória.
- **FR-010**: Ao confirmar o banimento ou suspensão de um usuário, o sistema DEVE invalidar imediatamente todas as sessões e tokens de acesso ativos da referida conta.
- **FR-011**: O sistema DEVE permitir a reversão de banimento ("Desbanir Usuário"), restaurando as permissões de acesso da conta mediante justificativa do administrador.
- **FR-012**: O sistema DEVE registrar de forma imutável toda e qualquer ação de moderação em uma trilha de auditoria contendo ID do moderador, alvo, tipo de ação, justificativa e carimbo de data/hora (timestamp).

### Accessibility Requirements (WCAG 2.1 AA) *(mandatory per Constitution)*

- **AR-001**: O sistema DEVE fornecer compatibilidade total com leitores de tela nativos (TalkBack, VoiceOver e leitores Web), assegurando que todas as tabelas de dados, modais de confirmação, botões de ação e alertas de denúncia possuam rótulos (`aria-label`/`Semantics`), papéis acessíveis e avisos de status dinâmico (`aria-live`).
- **AR-002**: O sistema DEVE garantir taxa de contraste mínima de 4.5:1 para texto normal e 3:1 para textos ampliados, badges de status (ex: badges de "Pendente", "Ocultado", "Banido") e componentes gráficos interativos, além de suporte total ao tema de Alto Contraste.
- **AR-003**: O sistema DEVE suportar ampliação dinâmica de fontes e zoom de até 200% sem quebra de leiaute, sobreposição de dados em tabelas ou perda de botões acionadores.
- **AR-004**: Todos os elementos interativos, menus e botões de ação do painel DEVEM respeitar o alvo de toque mínimo de 48x48 dp e permitir operação integral via teclado físico e dispositivos switch.

### Privacy & LGPD Requirements *(mandatory per Constitution)*

- **PR-001**: A trilha de auditoria e as telas de moderação DEVEM praticar minimização de dados, exibindo apenas dados estritamente pertinentes à decisão de moderação, sem expor senhas, documentos pessoais ou dados sensíveis de saúde desnecessários.
- **PR-002**: A identidade dos usuários denunciantes DEVE ser protegida no painel de moderação com acesso restrito a administradores autorizados, evitando retaliações e preservando a confidencialidade do canal de denúncias.
- **PR-003**: Em conformidade com o Art. 16 da LGPD, a exclusão de dados a pedido do titular não anula o dever de guarda e retenção de registros de auditoria de segurança e ilícitos para cumprimento de obrigação legal.

### Key Entities *(include if feature involves data)*

- **Report (Denúncia)**: Representa uma comunicação de infração feita por um usuário sobre um conteúdo ou conta. Atributos: identificador, recurso denunciado (tipo e ID), denunciante (ID), categoria/motivo do reporte, justificativa complementar, status (Pendente, Aceita, Rejeitada), moderador responsável, data de criação e data de resolução.
- **ModerationAction (Ação de Moderação / Log de Auditoria)**: Representa um ato formal executado por um administrador. Atributos: identificador, ID do administrador, tipo de ação (Ocultar, Restaurar, Excluir, Banir, Desbanir, RejeitarDenúncia), recurso alvo (tipo e ID), justificativa declarada, metadados contextuais e timestamp imutável.
- **UserPenalty (Penalidade de Usuário)**: Representa a sanção aplicada a uma conta de usuário no escalonamento progressivo. Atributos: identificador, usuário penalizado, tipo de penalidade (Advertência, Suspensão Temporária de 7 dias, Banimento Permanente), data de início, data prevista de término (se temporária), motivo formal, ID do administrador sancionador e status (Ativa, Expirada, Revogada).
- **ModeratedContent (Conteúdo Moderável)**: Abstração dos itens postados sujeitos a intervenção (Tópico de Fórum, Comentário/Subthread, Avaliação de Local, Fotos/Mídias). Atributos: identificador, tipo de entidade, autor original, status de moderação (Ativo, Ocultado, Excluído), contador de denúncias ativas e histórico de alterações de visibilidade.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Administradores conseguem localizar e aplicar moderação sobre uma publicação denunciada em menos de 60 segundos a partir do painel.
- **SC-002**: 100% das ações de moderação (ocultar, excluir, advertir, suspender, banir) geram registro imediato e auditável com justificativa formal associada.
- **SC-003**: Usuários suspensos ou banidos têm seus tokens e sessões invalidados no sistema em até 2 segundos após a confirmação da sanção.
- **SC-004**: Conteúdos marcados como "Ocultado" ou "Excluído" deixam de ser servidos a usuários públicos em 100% das consultas subsequentes de listagem e detalhe.
- **SC-005**: 100% das telas e fluxos do painel administrativo atingem conformidade com WCAG 2.1 AA sem barreiras de teclado ou leitor de tela.

## Assumptions

- O sistema já dispõe de autenticação baseada em tokens e suporte a perfis de usuário com diferenciação de papéis (Role: 'user', 'admin').
- A moderação é reativa baseada em denúncias comunitárias combinada com busca proativa por administradores, sem obrigatoriedade de aprovação prévia manual antes da publicação de cada post.
- Toda ação de moderação executada exige uma justificativa textual do administrador para alimentar o histórico de auditoria.
- A comunicação de banimento ou suspensão na tela de login fornece indicação clara do motivo e canal institucional de contato para casos de contestação de penalidade.
