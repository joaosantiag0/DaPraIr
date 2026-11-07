# Feature Specification: Sistema de Gamificação (Pontuação por Conteúdo e Ranking de Usuários)

**Feature Branch**: `003-gamificacao-pontos-ranking`  
**Created**: 2026-11-05  
**Status**: Ready for Planning  
**Input**: User description: "quero fazer um sistema de gameficação onde ao criar conteúdo a pessa ganha ponto, e um ranking de usuário"

## Clarifications

### Session 2026-11-05
- Q: Quais ações de criação de conteúdo devem pontuar e qual a proporção de peso entre elas? → A: **Modelo de Progressão por Qualidade**: Avaliação básica de local (15 pts) + bônus de foto comprobatória de acessibilidade (+10 pts por foto válida, com limite de 3 fotos / 30 pts por avaliação) + bônus de utilidade quando a avaliação for marcada como "Útil" por outros usuários (+25 pts). No fórum comunitário, criação de tópico relevante (10 pts) e resposta marcada como útil ou solução (+20 pts).
- Q: Quais modalidades e janelas temporais devem ser disponibilizadas no ranking (Leaderboard)? → A: **Triplo Período (Semanal, Mensal e Geral)**: O Leaderboard disponibiliza abas de seleção com atualização em tempo real para três visões: Semanal (ciclo dinâmico com reinício semanal aos domingos), Mensal (visão padrão com reinício a cada dia 1º) e Geral (histórico acumulado de todos os tempos da plataforma).
- Q: Qual a política de privacidade e visibilidade padrão ao participar do ranking comunitário (LGPD)? → A: **Visível com Apelido por Padrão (Opt-out)**: Ao pontuar, o usuário entra no ranking exibindo seu nome público ou apelido comunitário, mantendo autonomia total para, a qualquer instante nas configurações de privacidade, ativar o modo pseudônimo anônimo ou se ocultar integralmente do ranking público.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pontuação Automática por Criação de Conteúdo (Priority: P1)

Como uma pessoa cadastrada na plataforma DáPraIr? (usuária com deficiência física, acompanhante ou aliada), quero receber pontos automaticamente ao contribuir com conteúdos úteis (como registrar avaliações detalhadas de acessibilidade de locais, anexar fotos comprobatórias de rampas/banheiros e publicar tópicos ou respostas resolutivas no fórum), para que minha dedicação em mapear e fortalecer a comunidade de acessibilidade seja reconhecida.

**Why this priority**: É o motor principal da gamificação. Sem a mecânica de atribuir e registrar pontos vinculados a ações de valor comunitário, não existe base para níveis, conquistas ou rankings.

**Independent Test**: Pode ser testado de forma isolada criando uma avaliação de local com fotos ou publicando um tópico no fórum com um usuário autenticado e verificando se o saldo de pontos do usuário é incrementado imediatamente de acordo com as regras estabelecidas, gerando o respectivo registro no extrato.

**Acceptance Scenarios**:

1. **Given** um usuário logado na tela de avaliação de um local, **When** ele conclui e publica uma avaliação completa com notas de critérios de acessibilidade e 2 fotos comprobatórias, **Then** o sistema credita 35 pontos (15 base + 20 de bônus por fotos) ao usuário, exibe notificação acessível de confirmação e atualiza o extrato de pontos.
2. **Given** uma avaliação publicada por um usuário, **When** outros membros da comunidade interagem e marcam a avaliação como "Útil", **Then** o autor recebe automaticamente um bônus adicional de 25 pontos por utilidade comunitária.
3. **Given** um usuário participando da comunidade no fórum, **When** ele cria um novo tópico relevante (10 pts) ou publica uma resposta que é marcada como útil/solução (+20 pts), **Then** o sistema adiciona a pontuação devida ao seu perfil.
4. **Given** uma ação já pontuada que venha a ser excluída pelo autor ou removida por moderação (ex: avaliação falsa ou ofensiva), **Then** os pontos concedidos previamente para aquela ação são estornados do saldo do usuário com justificativa registrada no histórico.

---

### User Story 2 - Consulta ao Ranking de Usuários (Leaderboard) (Priority: P1)

Como membro da comunidade, quero visualizar um ranking com os usuários mais participativos e colaboradores da plataforma, identificando sua posição relativa, pontuação acumulada e insígnias conquistadas, alternando entre visões semanal, mensal e geral, para me sentir motivado a colaborar mais e conhecer os maiores contribuidores de acessibilidade.

**Why this priority**: O ranking dá visibilidade social ao esforço dos usuários e concretiza a competitividade saudável e o reconhecimento público que sustentam o engajamento comunitário.

**Independent Test**: Pode ser testado acessando a aba ou tela de "Ranking / Colaboradores", alternando entre as abas Semanal, Mensal e Geral, verificando a ordenação decrescente por pontuação e a exibição clara da posição do usuário corrente.

**Acceptance Scenarios**:

1. **Given** um usuário autenticado na tela de Ranking, **When** ele navega pela aba padrão "Mensal", **Then** visualiza a lista dos principais colocados no mês corrente ordenada por pontuação, destacando também a sua própria posição relativa e a distância em pontos para o colocador imediatamente superior.
2. **Given** um usuário na tela de Ranking, **When** ele alterna para a aba "Semanal" ou "Geral (Todos os Tempos)", **Then** a listagem é reordenada exibindo os dados acumulados correspondentes à janela temporal selecionada.
3. **Given** um visitante não autenticado (modo convidado), **When** ele abre a tela de Ranking, **Then** visualiza a lista pública dos usuários líderes com seus nomes públicos/apelidos e pontuações, sem possibilidade de interagir ou pontuar até realizar login.
4. **Given** um leitor de tela (TalkBack/VoiceOver) ativo na tela de ranking, **When** o usuário percorre a lista de posições, **Then** o leitor anuncia claramente a posição ordinal (ex: "1º lugar"), nome do usuário, pontuação e insígnia conquistada, sem perda de contexto ou leituras ambíguas.

---

### User Story 3 - Níveis de Engajamento, Insígnias (Badges) e Extrato de Conquistas (Priority: P2)

Como usuário ativo, quero acompanhar meu progresso acumulado através de níveis hierárquicos (ex: "Explorador Iniciante", "Mapeador Ativo", "Embaixador da Acessibilidade") e desbloquear medalhas/insígnias temáticas conforme atinjo marcos específicos de contribuição, consultando meu extrato detalhado de pontuação.

**Why this priority**: Fornece metas contínuas de longo prazo para os usuários, evitando que usuários que entraram recentemente desanimem diante de líderes históricos inalcançáveis no topo do ranking geral.

**Independent Test**: Pode ser testado simulando o alcance de pontuação necessária para mudança de nível ou conquista de badge e verificando a atualização do perfil do usuário e a emissão do evento de conquista.

**Acceptance Scenarios**:

1. **Given** um usuário cujo total de pontos atinge o limiar para um novo nível de engajamento, **When** a pontuação é computada, **Then** seu perfil é atualizado com o novo título/nível e o usuário recebe uma notificação congratulatória com descrição das vantagens ou destaque obtido.
2. **Given** um usuário na tela do seu perfil ou na aba de gamificação, **When** ele seleciona "Extrato de Pontos", **Then** o sistema apresenta a lista cronológica de todas as entradas e estornos de pontos com data, descrição da ação que originou os pontos e variação de saldo.

---

### User Story 4 - Privacidade, Consentimento e Anonimato no Ranking (LGPD) (Priority: P2)

Como usuário com deficiência ou aliado preocupado com privacidade, quero ter controle total sobre como meu nome e perfil aparecem no ranking público de gamificação, podendo optar por exibir meu nome público, um apelido anônimo ou me ocultar totalmente do ranking público sem perder o registro interno dos meus pontos.

**Why this priority**: Requisito mandatório pela Constituição do projeto (Princípio IV - Privacidade e LGPD). Usuários não podem ser forçados a expor publicamente sua atividade, identidade ou frequência de participação.

**Independent Test**: Pode ser testado alterando as configurações de privacidade de gamificação para "Modo Anônimo" ou "Ocultar do Ranking Público" e verificando se a listagem pública omite a identidade ou o registro do usuário conforme solicitado.

**Acceptance Scenarios**:

1. **Given** um usuário cadastrado participando do ranking, **When** ele mantém o padrão inicial do sistema (opt-out), **Then** seu registro no ranking exibe seu nome público ou apelido cadastrado.
2. **Given** um usuário que prefere não expor sua identidade pessoal, **When** acessa as configurações de gamificação no perfil e ativa a opção "Exibir apenas apelido/pseudônimo", **Then** seu registro no ranking passa a exibir o apelido escolhido em vez do nome civil.
3. **Given** um usuário que seleciona a opção "Ocultar meu perfil do ranking público", **When** outros usuários consultam o ranking geral ou periódico, **Then** o usuário oculto não figura na lista pública visível, mas continua acumulando seus pontos e níveis de forma privada em seu painel pessoal.

---

### User Story 5 - Salvaguardas Anti-Abuso e Limites Diários de Pontuação (Priority: P3)

Como moderador e gestor da plataforma comunitária, quero que o sistema possua regras e limites que impeçam comportamento de spam ou geração massiva de conteúdos de baixa qualidade visando apenas acumular pontos no ranking, garantindo a integridade dos dados de acessibilidade.

**Why this priority**: Protege o ecossistema contra fraudes que poluiriam o mapa de acessibilidade com avaliações vazias ou falsas em busca de posições de destaque.

**Independent Test**: Pode ser testado simulando a criação de dezenas de avaliações em um curto período com o mesmo usuário e verificando a aplicação dos tetos diários e travas de repetição.

**Acceptance Scenarios**:

1. **Given** um usuário que já atingiu o teto diário de pontos por envio de avaliações, **When** ele publica uma nova avaliação no mesmo dia, **Then** a avaliação é cadastrada normalmente na plataforma (não bloqueando a contribuição), porém com aviso de que o limite diário de bonificação de pontos para aquela categoria foi atingido.
2. **Given** múltiplas avaliações duplicadas ou fotos repetidas postadas para o mesmo estabelecimento pelo mesmo usuário, **Then** o sistema pontua unicamente a primeira contribuição válida naquele intervalo.

---

### Edge Cases

- O que acontece quando dois ou mais usuários empatam exatamente na mesma pontuação no ranking? O sistema adota critério de desempate claro (antiguidade da conquista dos pontos ou data de cadastro) e exibe a mesma posição com numeração compartilhada (ex: ambos como 3º lugar).
- Como o sistema trata a exclusão definitiva da conta de um usuário ("direito ao esquecimento" LGPD)? Todos os registros históricos vinculados à sua identidade são anonimizados ou removidos do ranking público imediatamente, recalculando as posições dos demais usuários.
- O que ocorre se um conteúdo avaliado for denunciado e ocultado para moderação? Os pontos permanecem retidos condicionalmente e, caso a denúncia seja julgada procedente por violação das diretrizes, os pontos são estornados definitivamente.
- Como o ranking se comporta quando o usuário está sem conexão com a internet (modo offline)? O extrato e ranking exibem os dados armazenados no último cache local com indicador claro de "Visualizando dados sincronizados em [data/hora]".

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema DEVE atribuir pontos automaticamente ao usuário autenticado sempre que ele publicar conteúdo elegível (avaliação de acessibilidade de local com notas de critérios, upload de fotos comprobatórias de acessibilidade, publicação de novo local acessível, criação de tópicos no fórum e respostas marcadas como úteis).
- **FR-002**: O sistema DEVE adotar a tabela padronizada de pontuação por Progressão por Qualidade:
  - Avaliação de acessibilidade básica (critérios preenchidos): **+15 pontos**;
  - Bônus por foto comprobatória de acessibilidade: **+10 pontos por foto válida** (limite de 3 fotos / máximo de +30 pontos por avaliação);
  - Bônus comunitário de utilidade: **+25 pontos** quando a avaliação receber a marcação de "Avaliação Útil" por outros membros;
  - Criação de tópico no fórum de discussão: **+10 pontos**;
  - Publicação de resposta marcada como útil ou solução no fórum: **+20 pontos**.
- **FR-003**: O sistema DEVE manter um extrato detalhado de pontos por usuário contendo: identificador da transação, data/hora, tipo de ação, identificador do conteúdo originador, quantidade de pontos creditados ou debitados e saldo resultante.
- **FR-004**: O sistema DEVE suportar estorno de pontos (débito) caso o conteúdo originador seja excluído pelo autor ou reprovado/removido pela equipe de moderação.
- **FR-005**: O sistema DEVE calcular e exibir um ranking de usuários (Leaderboard) ordenado de forma decrescente pela pontuação acumulada.
- **FR-006**: O ranking DEVE disponibilizar visualização por três janelas temporais selecionáveis via abas na interface:
  - **Semanal**: pontuação acumulada na semana corrente (com reinicialização aos domingos às 23:59);
  - **Mensal** (visão padrão): pontuação acumulada no mês corrente (com reinicialização no primeiro minuto do dia 1º de cada mês);
  - **Geral**: pontuação total histórica acumulada desde o cadastro.
- **FR-007**: O sistema DEVE exibir em destaque o posicionamento do usuário autenticado no ranking, incluindo sua posição ordinal relativa e a distância em pontos para o próximo colocador.
- **FR-008**: O sistema DEVE disponibilizar níveis de engajamento progressivos com base no acúmulo total de pontos (ex: Nível 1 - Explorador, Nível 2 - Colaborador, Nível 3 - Mapeador, Nível 4 - Especialista, Nível 5 - Embaixador).
- **FR-009**: O sistema DEVE implementar regras de prevenção a spam e abuso, incluindo um limite máximo diário de pontos ganhos por categoria de conteúdo, prevenindo fraudes de acúmulo artificial.
- **FR-010**: O sistema DEVE adotar a política de visibilidade de Opt-out no ranking comunitário: usuários autenticados ingressam no ranking exibindo seu nome público ou apelido por padrão, podendo alternar a qualquer momento nas preferências de privacidade para modo pseudonimizado ("Usuário Anônimo") ou ocultar-se integralmente do ranking público sem perda de seus pontos privados.
- **FR-011**: Visitantes não autenticados (Modo Convidado) DEVEM conseguir consultar o ranking público dos usuários mais ativos, sem acesso a dados sensíveis de contato ou histórico privado.

### Accessibility Requirements (WCAG 2.1 AA) *(mandatory per Constitution)*

- **AR-001**: O sistema DEVE fornecer suporte integral a leitores de tela (TalkBack, VoiceOver e leitores Web), anunciando semântica apropriada para posições do ranking (ex: "Posição 1, Maria Silva, 1200 pontos, Nível Embaixadora"), medalhas e variações de pontuação com `Semantics` adequados no Flutter.
- **AR-002**: A interface gráfica do ranking, extrato e distintivos de níveis DEVE garantir taxa de contraste mínima de 4.5:1 para texto normal e 3:1 para elementos gráficos/ícones de medalhas, suportando o tema de Alto Contraste nativo da plataforma.
- **AR-003**: O sistema DEVE suportar a escala dinâmica de fontes do sistema operacional sem truncar textos, sobrepor itens do ranking ou quebrar a exibição de pontuações extensas.
- **AR-004**: Todos os elementos interativos (itens do ranking, filtros temporais, paginação e botões de extrato) DEVEM respeitar o alvo de toque mínimo de 48x48 dp e permitir navegação fluida por teclado físico e dispositivos assistivos.
- **AR-005**: O sistema NÃO DEVE utilizar apenas cor para indicar posição de destaque no ranking (ex: além de cores ouro/prata/bronze, deve exibir claramente o ícone semântico e o numeral ordinal textual "1º", "2º", "3º").

### Privacy & LGPD Requirements *(mandatory per Constitution)*

- **PR-001**: O sistema DEVE respeitar o princípio da minimização de dados, exibindo no ranking público estritamente o avatar escolhido, o nome público/apelido, a pontuação acumulada e o selo de nível, sem jamais expor dados pessoais sensíveis (deficiências, dados médicos ou localização precisa de residência).
- **PR-002**: O sistema DEVE fornecer opções transparentes de privacidade de gamificação, permitindo que o usuário alterne entre (a) Nome público visível, (b) Apelido anônimo e (c) Perfil totalmente oculto do ranking público.
- **PR-003**: O sistema DEVE permitir a portabilidade do extrato de gamificação, possibilitando ao usuário exportar seu histórico completo de pontos e conquistas.
- **PR-004**: Em caso de solicitação de exclusão de conta ("direito ao esquecimento"), todos os registros de pontuação associados ao usuário DEVEM ser desvinculados ou expurgados, retirando o usuário imediatamente do ranking público.

### Key Entities *(include if feature involves data)*

- **PontuacaoTransacao**: Registro individual e imutável de crédito ou débito de pontos. Atributos: `id`, `usuario_id`, `tipo_acao` (ex: AVALIACAO_LOCAL, BONUS_FOTO_ACESSIBILIDADE, BONUS_UTILIDADE, TOPICO_FORUM, RESPOSTA_UTIL, ESTORNO), `quantidade_pontos`, `conteudo_referencia_id`, `conteudo_tipo`, `data_criacao`, `motivo_estorno`.
- **SaldoGamificacaoUsuario**: Saldo consolidado e estado de gamificação do usuário. Atributos: `usuario_id`, `pontos_totais_historicos`, `pontos_saldo_atual`, `nivel_atual`, `data_atualizacao`.
- **NivelBadge**: Definição de níveis de progressão e insígnias. Atributos: `id`, `identificador_chave`, `nome_nivel`, `pontuacao_minima`, `descricao`, `icone_url`, `ordem`.
- **RankingRegistro**: Snapshot ou visão calculada de posições em janelas temporais. Atributos: `usuario_id`, `posicao`, `pontos_periodo`, `periodo_tipo` (SEMANAL, MENSAL, GERAL), `periodo_referencia`.
- **PreferenciaGamificacaoUsuario**: Configuração de privacidade de gamificação. Atributos: `usuario_id`, `exibir_no_ranking_publico` (booleano), `formato_identificacao` (NOME_PUBLICO, APELIDO_ANONIMO).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: O crédito de pontos e a atualização do saldo do usuário ocorrem de forma imediata e perceptível, com notificação de confirmação exibida em menos de 1 segundo após a publicação do conteúdo elegível.
- **SC-002**: A tela de Ranking carrega e exibe as 50 primeiras posições e a posição relativa do usuário em menos de 1.5 segundos em redes móveis convencionais (4G/5G).
- **SC-003**: 100% dos elementos da tela de ranking, insígnias e extrato de pontos passam na validação de acessibilidade com leitores de tela (TalkBack e VoiceOver) sem rotulações ausentes ou confusas.
- **SC-004**: A introdução da mecânica de gamificação eleva em pelo menos 35% o volume mensal de avaliações de acessibilidade e fotos registradas nos primeiros 60 dias após o lançamento.
- **SC-005**: 100% dos usuários têm garantido o direito de alterar sua visibilidade no ranking ou ocultar seu perfil a qualquer momento através das preferências de privacidade.

---

## Assumptions

- O sistema existente de autenticação e perfis de usuários (Spec 001) já fornece o identificador único de usuário e o contexto de sessão ativa.
- Os módulos de Avaliação de Locais (Spec 001) e Tópicos do Fórum (Spec 002) expõem eventos ou ganchos de ciclo de vida (hooks) que disparam a notificação de criação/remoção de conteúdo para o mecanismo de gamificação.
- As ações de pontuação não envolvem transações financeiras nem recompensas monetárias diretas no MVP, tratando-se exclusivamente de reconhecimento comunitário, níveis e reputação social.
- Em caso de indisponibilidade momentânea da sincronização online de ranking, a interface exibirá mensagem de estado amigável com opção de repetição, sem travar a navegação do aplicativo.
