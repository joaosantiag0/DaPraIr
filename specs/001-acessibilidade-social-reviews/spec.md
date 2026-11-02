# Feature Specification: AcessoJá - Plataforma Social e Avaliações de Acessibilidade Física

**Feature Branch**: `001-acessibilidade-social-reviews`  
**Created**: 2026-11-02  
**Status**: Draft  
**Input**: User description: "AcessoJá - Rede Social + Avaliações de Acessibilidade para Pessoas com Deficiência Física (MVP)"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Descoberta e Avaliação Detalhada de Acessibilidade de Locais (Priority: P1)

Como uma pessoa com deficiência física (usuária de cadeira de rodas ou mobilidade reduzida), quero pesquisar locais no mapa ou por filtros de acessibilidade, consultar notas por critérios específicos (rampa, banheiro, manobra), ver fotos reais e cadastrar minhas próprias avaliações para planejar minhas saídas com segurança e autonomia.

**Why this priority**: É o valor central do produto ("o coração da plataforma"). Sem a capacidade de descobrir e registrar dados confiáveis de acessibilidade física com critérios objetivos e fotos reais, o propósito da comunidade não se sustenta.

**Independent Test**: Pode ser testado de ponta a ponta criando um perfil de usuário, navegando pelo mapa ou busca filtrada, abrindo os detalhes de um local, visualizando fotos/notas por critério e submetendo uma nova avaliação com fotos e notas específicas para cada item de acessibilidade.

**Acceptance Scenarios**:

1. **Given** um usuário logado na tela de detalhes de um restaurante, **When** ele seleciona a opção "Avaliar Acessibilidade", preenche notas para Entrada (rampa/nível), Banheiro Adaptado, Espaço de Manobra, Mesas Adaptadas, Estacionamento e Atendimento, anexa ao menos uma foto comprobatória e confirma o envio, **Then** a avaliação é publicada imediatamente, atualizando a média geral do local, as médias de cada critério e a data de última verificação.
2. **Given** um usuário buscando um local para almoçar, **When** ele aplica os filtros "Banheiro Adaptado" e "Entrada Nivelada/Rampa", **Then** a listagem e o mapa exibem exclusivamente estabelecimentos que atendem a esses critérios confirmados por avaliações recentes.
3. **Given** um local com última avaliação realizada há mais de 12 meses, **When** o usuário abre a página do local, **Then** o sistema exibe um alerta de "Necessita de verificação recente" convidando frequentadores a atualizarem as informações.

---

### User Story 2 - Cadastro Inclusivo, Perfil e Gestão Granular de Privacidade (Priority: P1)

Como usuário com deficiência física, acompanhante ou cuidador, quero criar meu perfil informando (se desejar) meus tipos de deficiência, preferências de acessibilidade, interesses e mobilidade, tendo controle absoluto sobre a visibilidade de cada dado sensível (público, somente conexões/amigos ou estritamente privado).

**Why this priority**: Estabelece a identidade do usuário e o consentimento explícito em conformidade com as leis de proteção de dados sensíveis (LGPD). É requisito primordial para habilitar interações sociais seguras e personalização do conteúdo.

**Independent Test**: Pode ser testado realizando o onboarding de um novo usuário, configurando as opções de acessibilidade e privacidade no perfil e verificando através de outra conta pública que os dados marcados como privados ou restritos a amigos não são expostos.

**Acceptance Scenarios**:

1. **Given** um novo usuário durante o cadastro, **When** chega na etapa de perfil de acessibilidade, **Then** o sistema permite selecionar tipos de deficiência (ex: usuária de cadeira de rodas, limitação de membros, mobilidade reduzida) e preferências (ex: rampa, elevador, banheiro adaptado), informando claramente que esses dados são opcionais e sensíveis.
2. **Given** um usuário que configurou seu tipo de deficiência como "Apenas Amigos" ou "Privado", **When** um usuário não autorizado ou não conectado visualiza seu perfil público, **Then** as informações de deficiência e mobilidade não são exibidas.
3. **Given** um usuário ativo, **When** ele acessa as configurações de privacidade da conta, **Then** ele pode alterar a visibilidade de qualquer campo a qualquer momento, exportar seus dados pessoais cadastrados ou solicitar a exclusão definitiva de sua conta.

---

### User Story 3 - Conexões Sociais e Comunicação Direta entre Pares (Priority: P2)

Como pessoa com deficiência física, quero encontrar pessoas próximas ou com perfis e necessidades de acessibilidade semelhantes, conectar-me através do envio de solicitações de amizade/seguir e interagir via chat privado 1:1 para trocar experiências reais sobre lugares e rotas.

**Why this priority**: Promove o senso de comunidade e suporte mútuo, reduzindo o isolamento social frequentemente enfrentado por pessoas com mobilidade reduzida.

**Independent Test**: Pode ser testado visualizando a seção de sugestões de conexões na tela principal ou na aba social, enviando solicitação para outro usuário, aceitando o vínculo e trocando mensagens de texto no chat direto 1:1.

**Acceptance Scenarios**:

1. **Given** dois usuários cadastrados com interesses em comum e preferências de acessibilidade compatíveis na mesma região, **When** um usuário acessa a seção de conexões, **Then** o sistema apresenta a recomendação de perfil com base nas afinidades públicas compartilhadas.
2. **Given** uma conexão aceita entre dois usuários, **When** um deles envia uma mensagem de texto pelo chat privado, **Then** o destinatário recebe notificação instantânea e pode responder em um canal de conversa protegido.
3. **Given** um usuário recebendo mensagens indesejadas, **When** ele aciona a opção de bloquear ou denunciar usuário, **Then** a conversa é imediatamente suspensa e o usuário bloqueado perde qualquer capacidade de contato.

---

### User Story 4 - Descoberta e Divulgação de Eventos Inclusivos (Priority: P2)

Como organizador ou participante da comunidade, quero criar e descobrir eventos (encontros, passeios, palestras, esportes adaptados) com declaração obrigatória de condições de acessibilidade do local, confirmar presença e interagir com outros participantes.

**Why this priority**: Transforma a informação digital em encontros no mundo real, garantindo que os usuários não cheguem a um evento para encontrar barreiras arquitetônicas inesperadas.

**Independent Test**: Pode ser testado criando um novo evento com data, local, descrição e checklist obrigatório de acessibilidade, e em seguida confirmando presença com outro usuário e visualizando a contagem de participantes.

**Acceptance Scenarios**:

1. **Given** um usuário organizando um encontro, **When** ele preenche o formulário de criação de evento, **Then** o sistema exige que sejam declaradas as condições de acessibilidade do espaço (ex: entrada nivelada, sanitário acessível, vagas reservadas) antes de permitir a publicação.
2. **Given** um usuário navegando pelo feed ou lista de eventos, **When** ele filtra por data ou critérios de acessibilidade, **Then** visualiza os eventos disponíveis com selo de condições declaradas e pode marcar "Confirmar Presença".
3. **Given** um participante confirmado em um evento, **When** acessa os detalhes do evento, **Then** visualiza a lista de participantes confirmados e o canal de avisos/chat do evento.

---

### User Story 5 - Feed Comunitário e Moderação de Conteúdo (Priority: P3)

Como membro da comunidade, quero visualizar um feed com atualizações de lugares recomendados, dicas de acessibilidade do dia e avaliações recentes de outros usuários, além de poder denunciar avaliações falsas ou inadequadas.

**Why this priority**: Mantém o engajamento diário, estimula novos feedbacks e protege a credibilidade das informações por meio de mecanismos comunitários de denúncia.

**Independent Test**: Pode ser testado rolando o feed principal da aplicação, interagindo com publicações recentes e reportando uma avaliação de teste com motivo de denúncia, confirmando que a equipe de moderação recebe o apontamento.

**Acceptance Scenarios**:

1. **Given** um usuário na tela inicial (Feed), **When** a página é carregada, **Then** são exibidos destaques de lugares bem avaliados por perto, últimas avaliações de conexões e dicas de acessibilidade.
2. **Given** uma avaliação que contenha fotos impróprias ou informações sabidamente falsas, **When** um usuário seleciona "Denunciar avaliação" e escolhe o motivo, **Then** a avaliação é marcada para moderação e o denunciante recebe confirmação de envio.

---

### Edge Cases

- **Sem conectividade à internet**: O aplicativo deve permitir navegação em dados e mapas previamente salvos em cache local e permitir o preenchimento de rascunhos de avaliação para envio assim que a conexão for restabelecida.
- **Local sem avaliações cadastradas**: Ao buscar um local não avaliado, a interface deve indicar de forma acolhedora que o espaço ainda não possui registros de acessibilidade e convidar o usuário a ser o primeiro a avaliá-lo.
- **Avaliações com notas contraditórias**: Se critérios objetivos forem preenchidos com notas divergentes (ex: nota alta para entrada, mas foto indicando degrau sem rampa), o sistema deve solicitar confirmação do usuário antes da publicação.
- **Perfis totalmente privados no matching**: Usuários com perfil 100% privado não devem ter seus dados expostos em listagens públicas ou sugestões abertas de conexões sem consentimento prévio para descoberta.
- **Tentativa de assédio ou spam no chat**: Limite de taxa de mensagens e botão acessível e evidente de bloqueio/denúncia em todas as telas de conversa direta.
- **Imagens pesadas ou de baixa resolução**: O sistema deve otimizar imagens no envio sem perda dos detalhes relevantes para identificação de acessibilidade (ex: altura de degraus, barras de apoio).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema DEVE permitir cadastro e autenticação de usuários por meio de e-mail e senha, telefone e provedores de identidade comuns (Google e Apple).
- **FR-002**: O sistema DEVE disponibilizar questionário de onboarding opcional para captura de tipo de deficiência física (cadeira de rodas motorizada/manual, mobilidade reduzida, limitação de membros, etc.) e preferências de acessibilidade.
- **FR-003**: O sistema DEVE permitir ao usuário definir a visibilidade de cada atributo do seu perfil entre três níveis: Público, Apenas Amigos/Conexões ou Privado (apenas o próprio usuário).
- **FR-004**: O sistema DEVE exibir badges de verificação de perfil e reputação (ex: "Usuário Verificado", "Avaliador Frequente", "Colaborador da Comunidade").
- **FR-005**: O sistema DEVE possibilitar busca de locais por nome, categoria (restaurante, shopping, parque, hotel, banco, academia, etc.) e localização geográfica atual ou endereço informado.
- **FR-006**: O sistema DEVE disponibilizar mapa interativo com marcadores visuais diferenciados por nível de acessibilidade geral do local.
- **FR-007**: O sistema DEVE permitir filtrar locais na busca e no mapa por critérios específicos: Entrada com rampa/nível, Elevador, Banheiro adaptado, Espaço de manobra para cadeira de rodas, Mesas/assentos adaptados, Estacionamento acessível e Atendimento inclusivo.
- **FR-008**: O sistema DEVE permitir a criação de avaliações de estabelecimentos contendo notas quantitativas individuais (escala de 1 a 5) para cada critério específico de acessibilidade física.
- **FR-009**: O sistema DEVE permitir o envio de fotos comprobatórias com descrição textual associada em cada avaliação realizada.
- **FR-010**: O sistema DEVE calcular e exibir a nota geral de acessibilidade do local, o detalhamento das notas médias por critério e a data da última avaliação submetida ("última verificação").
- **FR-011**: O sistema DEVE fornecer mecanismo de denúncia de avaliações suspeitas, incorretas ou ofensivas, com categorização do motivo da denúncia.
- **FR-012**: O sistema DEVE manter o histórico de locais visitados, salvos como favoritos e avaliados pelo próprio usuário.
- **FR-013**: O sistema DEVE sugerir conexões entre usuários com base em proximidade geográfica, interesses comuns e compatibilidade de preferências de acessibilidade compartilhadas publicamente.
- **FR-014**: O sistema DEVE possibilitar o envio de solicitações de amizade e a opção de seguir perfis de outros membros da comunidade.
- **FR-015**: O sistema DEVE prover chat privado direto (1:1) com mensagens de texto entre usuários conectados.
- **FR-016**: O sistema DEVE disponibilizar funcionalidades de bloqueio de contato e denúncia de usuários no canal de chat.
- **FR-017**: O sistema DEVE permitir a qualquer usuário criar e divulgar eventos inclusivos com título, data, horário, endereço, descrição e declaração obrigatória dos itens de acessibilidade do local.
- **FR-018**: O sistema DEVE possibilitar a confirmação de presença (RSVP) em eventos e a visualização da lista de participantes confirmados.
- **FR-019**: O sistema DEVE apresentar feed principal contendo: sugestões de locais acessíveis próximos, avaliações recentes da comunidade, sugestões de conexão e eventos programados.
- **FR-020**: O sistema DEVE suportar modo offline para consulta a locais previamente visitados ou salvos em favoritos, bem como criação de rascunhos de avaliação.

### Accessibility Requirements (WCAG 2.1 AA) *(mandatory per Constitution)*

- **AR-001**: O sistema DEVE fornecer suporte completo a leitores de tela nativos (TalkBack no Android, VoiceOver no iOS e tecnologias assistivas na Web), com semântica precisa, rótulos textuais significativos, papéis (roles) e descrições contextuais em todos os elementos visuais e interativos.
- **AR-002**: O sistema DEVE garantir taxa de contraste mínima de 4.5:1 para texto normal e 3:1 para texto ampliado e elementos gráficos essenciais de controle, disponibilizando tema nativo de Alto Contraste.
- **AR-003**: O sistema DEVE suportar redimensionamento dinâmico de fontes definido pelo sistema operacional do usuário, sem truncamento de texto, sobreposição ou quebra da usabilidade da interface.
- **AR-004**: Todas as áreas interativas e botões DEVEM respeitar o alvo de toque mínimo de 48x48 dp e permitir navegação integral por teclado físico, switches e comandos assistivos.

### Privacy & LGPD Requirements *(mandatory per Constitution)*

- **PR-001**: O sistema DEVE coletar unicamente os dados estritamente necessários para as finalidades do serviço, aplicando o princípio de minimização de dados (Privacy by Design).
- **PR-002**: O tratamento de dados pessoais sensíveis (informações sobre deficiência, saúde e necessidades específicas de mobilidade) DEVE ser condicionado a consentimento explícito, granular e destacado, com opção simples de alteração e revogação a qualquer momento.
- **PR-003**: O sistema DEVE disponibilizar mecanismos acessíveis para o exercício dos direitos dos titulares previstos na LGPD, incluindo visualização integral dos dados cadastrados, exportação para portabilidade, correção e exclusão definitiva da conta e dados associados ("direito ao esquecimento").
- **PR-004**: O sistema DEVE proteger todos os dados sensíveis em repouso e em trânsito com criptografia forte e manter registros de auditoria anonimizados, sendo vedada a gravação de dados pessoais sensíveis em logs operacionais ou de depuração.

---

### Key Entities *(include if feature involves data)*

- **Usuário (User Profile)**: Identificação cadastral, nome/apelido, foto, biografia, nível de verificação/badges, tipo de deficiência física (sensível/opcional), preferências de acessibilidade (sensível/opcional), configurações de privacidade por campo e termos de consentimento.
- **Local (Place)**: Identificador único, nome, endereço/geolocalização, categoria (restaurante, hotel, etc.), média geral de acessibilidade, médias individuais por critério, data da última avaliação e lista de mídias anexadas.
- **Avaliação de Acessibilidade (Place Review)**: Vínculo entre Usuário e Local, notas quantitativas por critério (entrada, elevador, banheiro, manobra, assentos, estacionamento, atendimento), comentário descritivo, fotos/vídeos anexados, data de criação e histórico de denúncias.
- **Critério de Acessibilidade (Accessibility Item)**: Definição padronizada de cada item avaliado (tipo de entrada, elevador, banheiro adaptado, manobra de cadeira, assentos acessíveis, estacionamento regulamentado, atendimento inclusivo).
- **Conexão Social (Social Connection / Friendship)**: Relação entre dois usuários, indicando estado (pendente, aceito, bloqueado) e data de início do vínculo.
- **Mensagem Direta (Direct Message)**: Registro de conversa 1:1 entre usuários conectados, com remetente, destinatário, texto, timestamp e status de leitura.
- **Evento Inclusivo (Event)**: Informações do encontro, organizador responsável, data/hora, local associado, declaração das condições de acessibilidade, limite e lista de presenças confirmadas.
- **Denúncia (Content Report)**: Registro gerado por usuário sobre conteúdo inadequado (avaliação, mensagem ou perfil), contendo motivo selecionado, descrição, data e status de moderação.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Usuários conseguem concluir o fluxo de cadastro e publicar uma avaliação completa de acessibilidade com fotos em menos de 3 minutos.
- **SC-002**: A busca de locais com aplicação de filtros múltiplos de acessibilidade exibe resultados relevantes no mapa e na lista em menos de 2,5 segundos em condições normais de rede móvel.
- **SC-003**: 100% dos fluxos de navegação e telas principais cumprem integralmente as diretrizes de acessibilidade WCAG 2.1 nível AA, comprovado por testes automatizados e validação com leitores de tela nativos (TalkBack e VoiceOver).
- **SC-004**: 100% dos dados sensíveis sobre tipo de deficiência e mobilidade marcados como privados ou restritos a amigos permanecem inacessíveis para usuários não autorizados, com conformidade estrita à LGPD.
- **SC-005**: Taxa de retenção de usuários no 30º dia (D30) atinge pelo menos 25% nos primeiros 6 meses após o lançamento.
- **SC-006**: A plataforma alcança um índice de recomendação líquida (NPS) igual ou superior a 45 entre os usuários ativos com deficiência física.
- **SC-007**: Pelo menos 85% dos locais avaliados contam com ao menos uma foto comprobatória de suas condições de acessibilidade física.

---

## Assumptions

- **Público Inicial**: O lançamento inicial do MVP focará no território brasileiro (iniciando pelos grandes centros urbanos e capitais como São Paulo), utilizando o idioma Português (Brasil).
- **Dispositivos e Conectividade**: Os usuários utilizam smartphones modernos com GPS integrado e suporte a tecnologias assistivas nativas (Android e iOS).
- **Moderação no MVP**: No estágio inicial (MVP), a moderação de denúncias de avaliações e conduta no chat será conduzida por equipe humana com fila de auditoria manual, sem dependência obrigatória de moderação automatizada por modelos complexos.
- **Autenticação**: A autenticação utilizará padrões modernos de identidade segura (OAuth2/OpenID Connect para Google e Apple, além de credenciais verificadas por e-mail/SMS).
- **Disponibilidade de Dados Cartográficos**: A geolocalização e os pontos de interesse básicos de estabelecimentos serão baseados em serviços de mapas consolidados, permitindo a sobreposição dos metadados de acessibilidade física gerados pela comunidade.
