# Feature Specification: Espaço de Debate e Fórum de Tópicos Categorizados

**Feature Branch**: `002-forum-topics-discussions`  
**Created**: 2026-11-04  
**Status**: Draft  
**Input**: User description: "quero fazer um espaco onde os usuarios consigam debater sobre assuntos por t'opicos que eles abram e seja dividido em categoirias, tanto o post principal, quanto os comentario devem poder ser publico, pra comunidade, ou so pra o autor, deve poder responder respostas criando uma subthread, ai os publicos podem ser exibidos para visitantes"

## Clarifications

### Session 2026-11-04
- Q: Qual é o destinatário/escopo exato de um comentário marcado como "Só para o autor"? → A: Autor do comentário + Autor do tópico (mensagem privada bidirecional no contexto do tópico).
- Q: Como deve funcionar a criação e gerenciamento das categorias do fórum? → A: Catálogo curado por Administradores (apenas administradores criam/editam/desativam categorias; usuários escolhem entre categorias ativas ao criar um tópico).
- Q: Os tópicos e comentários devem suportar sistema de curtidas ou votos (upvotes) nesta versão inicial (v1)? → A: Curtida simples (Upvote): Usuários autenticados podem curtir/descurtir tópicos e comentários (1 curtida por usuário por item, com contador público e filtro pelos mais curtidos).
- Q: Como deve funcionar a moderação e denúncia de tópicos ou comentários impróprios na v1? → A: Denúncia Comunitária (Reativa): Usuários autenticados podem denunciar publicações impróprias com motivo pré-definido; administradores analisam e podem moderar (ocultar ou remover) o conteúdo.
- Q: Qual deve ser o nível máximo de aninhamento visual e estrutural das subthreads? → A: Até 3 níveis com achatamento subsequente (aninhamento hierárquico até o 3º nível; respostas subsequentes no mesmo ramo são alinhadas visualmente ao nível 3 com citação "@usuario").

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Criação e Navegação de Tópicos em Categorias Temáticas (Priority: P1)

Como um usuário cadastrado da plataforma, desejo navegar por categorias temáticas e abrir tópicos de discussão definindo título, conteúdo e nível de visibilidade, para que outros membros ou o público em geral possam debater assuntos de interesse comum de forma organizada.

**Why this priority**: É a espinha dorsal de todo o espaço de debates. Sem a capacidade de criar tópicos categorizados e definir sua visibilidade inicial, não há base para comentários ou interações comunitárias.

**Independent Test**: Pode ser testado de ponta a ponta criando uma categoria, autenticando um usuário, publicando tópicos em diferentes categorias com diferentes níveis de visibilidade (Público, Comunidade, Só Autor) e verificando a listagem e acesso correto a esses tópicos.

**Acceptance Scenarios**:

1. **Given** um usuário autenticado na tela inicial do fórum, **When** seleciona uma categoria existente e clica em "Novo Tópico", preenche título, texto descritivo e seleciona visibilidade "Público", **Then** o tópico é publicado na categoria selecionada e fica visível imediatamente na listagem de tópicos.
2. **Given** um usuário autenticado criando um tópico, **When** seleciona visibilidade "Comunidade", **Then** o tópico é salvo com indicação visual de restrito a membros e não é acessível por visitantes anônimos.
3. **Given** um usuário autenticado criando um tópico, **When** seleciona visibilidade "Só para o autor", **Then** o tópico é salvo de forma privada, aparecendo unicamente para o próprio autor na sua listagem pessoal de tópicos.
4. **Given** um usuário tentando publicar um tópico, **When** submete o formulário com título vazio ou sem selecionar categoria, **Then** o sistema exibe mensagens de validação acessíveis e impede o envio até a correção dos campos obrigatórios.

---

### User Story 2 - Comentários e Respostas Aninhadas em Subthreads (Priority: P2)

Como um usuário cadastrado participando de uma discussão, desejo responder diretamente a um tópico ou a um comentário específico criando uma subthread encadeada, podendo escolher a visibilidade da minha resposta, para aprofundar debates em múltiplos níveis de diálogo.

**Why this priority**: O debate dinâmico exige conversas contextualizadas em formato de árvore/subthread para que múltiplas conversas paralelas sobre o mesmo tópico permaneçam legíveis e compreensíveis.

**Independent Test**: Pode ser testado publicando comentários de primeiro nível em um tópico existente e respondendo a um comentário específico, validando a renderização da subthread, a correta atribuição de autoria e o controle de visibilidade da resposta.

**Acceptance Scenarios**:

1. **Given** um usuário visualizando um tópico que possui permissão de interação, **When** escreve um comentário de primeiro nível e submete com visibilidade "Público", **Then** o comentário é adicionado à base do tópico com data, hora e autor visíveis.
2. **Given** um comentário já publicado no tópico, **When** outro usuário aciona "Responder" naquele comentário específico, redige uma réplica e submete, **Then** a resposta é exibida aninhada hierarquicamente logo abaixo do comentário original como parte de uma subthread.
3. **Given** um usuário respondendo a uma mensagem em uma subthread, **When** define a visibilidade da resposta como "Comunidade" em um tópico "Público", **Then** apenas membros autenticados da comunidade conseguem visualizar a resposta na subthread.
4. **Given** um usuário criando um comentário ou resposta, **When** define a visibilidade como "Só para o autor", **Then** o conteúdo daquela resposta fica visível apenas para o autor da resposta e para o autor do tópico principal.

---

### User Story 3 - Visualização e Navegação Pública para Visitantes Anônimos (Priority: P3)

Como um visitante não cadastrado (ou usuário não autenticado), desejo navegar pelas categorias, ler tópicos e acompanhar debates públicos, para que eu possa consumir informações da comunidade antes de decidir criar uma conta.

**Why this priority**: Permite indexação de conteúdo, alcance comunitário e atração de novos membros com transparência, mantendo estritamente protegidos os conteúdos restritos.

**Independent Test**: Pode ser testado acessando o fórum como visitante anônimo (sem sessão ativa), confirmando que tópicos e comentários públicos são legíveis, enquanto tópicos e respostas marcados como "Comunidade" ou "Só para o autor" permanecem inacessíveis e ocultos.

**Acceptance Scenarios**:

1. **Given** um visitante não autenticado acessando o fórum, **When** navega pelas categorias disponíveis, **Then** visualiza a lista de categorias e todos os tópicos marcados com visibilidade "Público".
2. **Given** um visitante não autenticado, **When** tenta acessar diretamente a URL ou identificador de um tópico marcado com visibilidade "Comunidade" ou "Só para o autor", **Then** o sistema oculta o conteúdo e exibe uma tela amigável convidando o visitante a fazer login ou criar conta.
3. **Given** um visitante lendo um tópico público com mistura de comentários públicos e restritos, **When** percorre as subthreads, **Then** apenas os comentários marcados como "Público" são exibidos, sem revelar dados ou conteúdo dos comentários restritos à comunidade.
4. **Given** um visitante lendo um debate público, **When** tenta acionar "Criar Tópico" ou "Responder", **Then** o sistema solicita autenticação, preservando o contexto de onde o usuário estava após o login.

---

### User Story 4 - Gerenciamento de Conteúdo e Exclusão Segura (Priority: P4)

Como um autor de tópicos ou comentários, desejo editar o texto de minhas publicações ou excluí-las quando necessário, garantindo que a exclusão preserve a integridade estrutural das subthreads existentes e respeite meu direito à exclusão de dados (LGPD).

**Why this priority**: Garante autonomia do usuário sobre seus dados e integridade das discussões em caso de exclusão de mensagens intermediárias na árvore de respostas.

**Independent Test**: Pode ser testado editando uma publicação existente e conferindo o selo de edição, bem como excluindo um comentário que possui respostas filhas, verificando que o conteúdo original é removido sem quebrar as subthreads subordinadas.

**Acceptance Scenarios**:

1. **Given** o autor de um comentário ou tópico, **When** solicita a edição do seu conteúdo dentro das regras do fórum, **Then** o texto é atualizado e o sistema sinaliza que o conteúdo foi editado.
2. **Given** um comentário pai que possui subthreads com respostas de outros membros, **When** o autor do comentário pai decide excluí-lo, **Then** o conteúdo pessoal e a identidade do autor são removidos (exibindo "[Comentário removido pelo autor]"), mas a estrutura da subthread e as respostas de terceiros permanecem visíveis e navegáveis.
3. **Given** um autor solicitando exclusão de um tópico sem respostas ou de sua própria conta, **When** confirma a solicitação, **Then** seus dados identificáveis e conteúdos são removidos conforme a política de privacidade e LGPD.

---

### Edge Cases

- **Tópico Privado com Tentativa de Compartilhamento**: Se o link de um tópico com visibilidade "Só para o autor" for compartilhado com outro usuário autenticado, este usuário recebe aviso amigável de que o conteúdo não existe ou é inacessível para ele.
- **Herança de Limites de Visibilidade**: Um comentário ou subthread não pode ter uma visibilidade mais permissiva que a do tópico em que se encontra (ex: em um tópico "Comunidade", uma resposta não pode ser exibida para visitantes anônimos externos mesmo se marcada como pública; a audiência máxima é limitada pela visibilidade do tópico pai).
- **Profundidade Elevada de Subthreads**: Quando uma cadeia de respostas ultrapassa múltiplos níveis de profundidade, a interface mantém a coerência visual e de navegação assistiva através de agrupamento e indicação explícita ("Respondendo a @usuario"), sem quebra de layout ou corte de tela.
- **Exclusão de Tópico com Discussão Ativa**: Se o autor de um tópico principal tentar excluir um tópico que já possui dezenas de comentários públicos da comunidade, o sistema solicita confirmação reforçada e aplica a regra de preservação das mensagens públicas ou desassociação de autoria conforme a governança LGPD.
- **Transição de Conectividade**: Caso a conexão caia durante o envio de um comentário em uma subthread, o sistema retém o texto digitado e fornece feedback claro de erro com opção de reenvio sem duplicar a mensagem.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema DEVE disponibilizar uma estrutura de categorias temáticas gerenciada exclusivamente por administradores, permitindo que usuários autenticados selecionem uma categoria ativa obrigatória ao criar tópicos.
- **FR-002**: Usuários autenticados DEVEM poder criar novos tópicos informando título, texto/descrição, categoria obrigatória e nível de visibilidade.
- **FR-003**: O sistema DEVE suportar 3 (três) níveis explícitos de visibilidade para tópicos e comentários:
  1. `Público`: Acessível por qualquer pessoa, incluindo visitantes não autenticados.
  2. `Comunidade`: Acessível exclusivamente por usuários cadastrados e autenticados.
  3. `Só para o autor`: Acessível de forma restrita (para tópicos, somente o criador; para comentários, somente o autor do comentário e o autor do tópico).
- **FR-004**: O sistema DEVE permitir que visitantes anônimos (não autenticados) visualizem todas as categorias e leiam todos os tópicos e comentários configurados com visibilidade `Público`.
- **FR-005**: O sistema NÃO DEVE exibir tópicos ou comentários com visibilidade `Comunidade` ou `Só para o autor` para visitantes anônimos.
- **FR-006**: Usuários autenticados DEVEM poder comentar diretamente em qualquer tópico que tenham permissão de leitura.
- **FR-007**: Usuários autenticados DEVEM poder responder diretamente a comentários já existentes, gerando subthreads aninhadas hierarquicamente até 3 níveis estruturais diretos; réplicas além do 3º nível DEVEM ser posicionadas mantendo o alinhamento visual com indicação explícita ("Em resposta a @usuario").
- **FR-008**: O autor de um comentário ou resposta DEVE poder definir individualmente o nível de visibilidade de sua mensagem (`Público`, `Comunidade`, `Só para o autor`), com o escopo máximo de exibição respeitando o limite do tópico de origem.
- **FR-009**: O sistema DEVE permitir recolher (colapsar) e expandir subthreads de respostas para facilitar a leitura de debates extensos.
- **FR-010**: Usuários autenticados DEVEM poder editar suas próprias postagens e comentários, com indicação visual de que a mensagem foi editada.
- **FR-011**: Usuários autenticados DEVEM poder excluir suas postagens e comentários.
- **FR-012**: Caso um comentário que possua sub-respostas subordinadas seja excluído pelo autor, o sistema DEVE substituir seu texto por mensagem neutra de remoção ("[Comentário removido pelo autor]") e desvincular a identificação do autor, mantendo intactas as respostas dos demais usuários.
- **FR-013**: O sistema DEVE exibir filtros e ordenações de tópicos dentro de cada categoria (mais recentes, mais curtidos, mais comentados e minhas participações).
- **FR-014**: O sistema DEVE exigir autenticação prévia caso um visitante anônimo tente criar um tópico, comentar ou votar/curtir.
- **FR-015**: Usuários autenticados DEVEM poder curtir e descurtir (remover curtida) tópicos e comentários (máximo de 1 voto por usuário por publicação), com contador visível a todos que possuem permissão de leitura daquela mensagem.
- **FR-016**: Usuários autenticados DEVEM poder denunciar tópicos ou comentários impróprios, selecionando uma categoria de violação (ex: spam, assédio, discurso de ódio ou violação de privacidade) e opcionalmente adicionando justificativa.
- **FR-017**: O sistema DEVE fornecer aos administradores visão das publicações denunciadas e capacidade de moderar (manter, ocultar ou remover) o conteúdo reportado.

### Accessibility Requirements (WCAG 2.1 AA) *(mandatory per Constitution)*

- **AR-001**: O sistema DEVE fornecer suporte integral a leitores de tela (TalkBack, VoiceOver e leitores Web), anunciando claramente o nível hierárquico de cada subthread (ex: "Resposta nível 2 a @usuario"), status de expansão/recolhimento e o nível de visibilidade da postagem.
- **AR-002**: O sistema DEVE garantir taxa de contraste mínima de 4.5:1 para texto normal e 3:1 para elementos de interface e textos informativos (badges de visibilidade, categorias e botões), suportando modo de Alto Contraste.
- **AR-003**: O sistema DEVE suportar ampliação dinâmica de fontes do sistema operacional sem truncamento de texto, sobreposição ou quebra da árvore de respostas em telas pequenas.
- **AR-004**: Todos os elementos interativos (botões de responder, colapsar/expandir subthread, seletor de visibilidade, links de autor) DEVEM possuir área de toque mínima de 48x48 dp e ser totalmente operáveis por navegação via teclado físico e acionadores (switches).
- **AR-005**: A estrutura das subthreads DEVE possuir indicação semântica navegável por cabeçalhos ou referências acessíveis para permitir que usuários com deficiência visual pulem blocos de discussão irrelevantes.

### Privacy & LGPD Requirements *(mandatory per Constitution)*

- **PR-001**: O sistema DEVE aplicar o princípio da minimização de dados, armazenando apenas o identificador do autor, texto do debate, carimbos temporais e nível de visibilidade selecionado.
- **PR-002**: O sistema DEVE garantir que tópicos e comentários marcados como "Só para o autor" ou "Comunidade" nunca sejam expostos em buscas públicas, feeds não autenticados ou metadados de compartilhamento (OpenGraph/SEO).
- **PR-003**: O sistema DEVE garantir o direito de exclusão e anonimização de dados do autor (direito ao esquecimento), permitindo que o usuário solicite a remoção ou anonimização de todas as suas contribuições no fórum.
- **PR-004**: O sistema DEVE fornecer exportação (portabilidade) clara dos tópicos e comentários gerados pelo próprio usuário caso solicitado.

### Key Entities *(include if feature involves data)*

- **Categoria**: Representa o agrupamento temático de debates (ex: Nome, Descrição amigável, Ícone representativo, Status ativo/inativo).
- **Tópico**: Representa a discussão principal aberta por um usuário (Título, Conteúdo/Corpo do texto, Categoria associada, Autor, Nível de Visibilidade [Público, Comunidade, Só Autor], Data de criação, Data de atualização, Indicador de edição).
- **Comentário / Mensagem da Thread**: Representa uma manifestação em uma discussão (Tópico de vinculação, Comentário pai de referência [nulo para primeiro nível, preenchido para subthreads], Autor, Conteúdo do texto, Nível de Visibilidade [Público, Comunidade, Só Autor], Data de criação, Data de atualização, Status [Ativo, Removido pelo Autor]).
- **Curtida / Voto**: Representa o apoio positivo de um usuário autenticado a um tópico ou comentário (Identificador do usuário, Referência ao tópico ou comentário, Data/hora do voto).
- **Denúncia / Sinalização de Conteúdo**: Alerta de infração emitido por um usuário sobre um tópico ou comentário (Autor da denúncia, Referência à publicação denunciada, Motivo da violação, Justificativa opcional, Status [Pendente, Analisada, Rejeitada, Conteúdo Removido], Data de registro).
- **Nível de Visibilidade**: Enumeração de controle de acesso (`PUBLICO`, `COMUNIDADE`, `AUTOR`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Visitantes anônimos conseguem carregar e ler tópicos e comentários públicos de qualquer categoria em menos de 2 segundos sob conexão móvel padrão.
- **SC-002**: 100% dos tópicos e comentários com visibilidade "Comunidade" ou "Só para o autor" são estritamente bloqueados contra visualização ou vazamento para visitantes anônimos em testes de segurança e privacidade.
- **SC-003**: Usuários cadastrados conseguem criar um novo tópico ou responder a uma subthread em menos de 1 minuto em fluxos padrão.
- **SC-004**: 100% dos componentes de subthread e controles de visibilidade atingem total conformidade com WCAG 2.1 AA (contraste >= 4.5:1, alvo de toque >= 48x48 dp e semântica de leitor de tela validada).
- **SC-005**: A exclusão de um comentário pai com respostas filhas preserva 100% da integridade da árvore de subthread sem deixar nós órfãos inacessíveis.

## Assumptions

- **Gestão de Categorias**: No escopo inicial, as categorias temáticas do fórum são gerenciadas e disponibilizadas pela equipe de administração da plataforma para assegurar organização e relevância temática.
- **Comentários "Só para o autor"**: Quando um comentário tem visibilidade configurada como "Só para o autor", ele é acessível exclusivamente pelo autor da resposta e pelo autor do tópico principal (funcionando como uma mensagem privada contextual entre eles dentro do tópico).
- **Limite de Audiência Pelo Tópico**: A visibilidade do tópico principal atua como um teto de privacidade. Se um tópico for restrito à "Comunidade", nenhum comentário dentro dele pode ser visto por visitantes anônimos externos, mesmo que individualmente marcado como "Público".
- **Profundidade Visual de Subthreads**: Para garantir legibilidade em telas de smartphones e acessibilidade para pessoas com baixa visão ou zoom ampliado, a árvore visual suporta até 3 níveis de recuo visual direto; a partir do 4º nível, as respostas adotam layout alinhado com indicação contextual explícita ("Em resposta a @nome_usuario") e âncora navegável.
- **Autenticação Existente**: O sistema reutiliza o ecossistema e sessões de usuários já existentes na plataforma para diferenciar visitantes anônimos de usuários autenticados.
