<!-- Sync Impact Report
Version change: Unversioned Template → 1.0.0
Ratification Date: 2026-11-02
Last Amended Date: 2026-11-02

Modified Principles:
- [PRINCIPLE_1_NAME] → I. Acessibilidade Universal como Prioridade Absoluta (WCAG 2.1 AA/AAA)
- [PRINCIPLE_2_NAME] → II. Código Limpo e Componentização Estrita (Clean Code & Modular Design System)
- [PRINCIPLE_3_NAME] → III. Testabilidade Contínua e Alta Cobertura (Mínimo de 80%)
- [PRINCIPLE_4_NAME] → IV. Privacidade por Padrão e Conformidade Rígida com a LGPD
- [PRINCIPLE_5_NAME] → V. Consistência Multiplataforma (Flutter) e Paridade por Contêineres (Docker + Node.js + PostgreSQL)

Added Sections:
- Stack Tecnológica e Padrões de Engenharia
- Processo de Desenvolvimento e Quality Gates
- Governança e Ciclo de Emendas

Removed Sections:
- Nenhuma seção estrutural removida (placeholders substituídos por definições concretas do projeto)

Templates Requiring Updates:
- .specify/templates/plan-template.md: ✅ Atualizado (gates de acessibilidade, testes, LGPD e arquitetura)
- .specify/templates/spec-template.md: ✅ Atualizado (requisitos mandatórios de acessibilidade e conformidade LGPD)
- .specify/templates/tasks-template.md: ✅ Atualizado (testes automatizados e de acessibilidade obrigatórios)

Follow-up TODOs:
- Nenhum placeholder deixado pendente.
-->

# DáPraIr? Constitution

## Core Principles

### I. Acessibilidade Universal como Prioridade Absoluta (WCAG 2.1 AA/AAA)
- **Conformidade de Acessibilidade**: Toda interface nas plataformas Web, Android e iOS DEVE atender rigorosamente às diretrizes WCAG 2.1 no nível AA, buscando nível AAA sempre que viável.
- **Suporte a Tecnologias Assistivas**: Suporte integral e obrigatório a leitores de tela nativos (TalkBack no Android, VoiceOver no iOS e leitores para Web). Todos os elementos interativos DEVEM conter semântica correta (`Semantics` no Flutter), rótulos claros, papéis (roles) e descrições contextuais de ação.
- **Contraste e Legibilidade**: Taxa de contraste mínima de 4.5:1 para texto normal e 3:1 para texto ampliado e elementos gráficos essenciais. O aplicativo DEVE suportar tema de Alto Contraste nativo.
- **Tipografia e Layout Responsivo**: Suporte obrigatório a fontes escaláveis definidas pelo sistema operacional sem truncamento, sobreposição de textos ou perda de usabilidade.
- **Área de Toque e Navegação Alternativa**: Elementos clicáveis DEVEM respeitar o alvo mínimo de toque de 48x48 dp. O sistema DEVE permitir navegação completa via teclado físico, switches e comandos assistivos.
- *Racional*: O objetivo primordial do produto "DáPraIr?" é promover inclusão e autonomia de pessoas com deficiência. Interfaces inacessíveis configuram quebra crítica de requisito e impedimento de entrega.

### II. Código Limpo e Componentização Estrita (Clean Code & Modular Design System)
- **Clean Architecture**: Separação clara e mandatória entre camadas de Apresentação (UI/Widgets), Domínio (Entidades e Casos de Uso/Regras de Negócio) e Dados (Repositórios, Provedores e Clientes de API). Regras de negócio NÃO DEVEM depender de frameworks ou bibliotecas externas.
- **Componentização e Reusabilidade**: A interface Flutter DEVE ser construída a partir de um Design System unificado e componentizado. Componentes DEVEM ser pequenos, puros, atômicos e reutilizáveis, garantindo que recursos de acessibilidade sejam incorporados diretamente nos blocos fundamentais de UI.
- **Padrões de Código Limpo**: Funções concisas com responsabilidade única (SRP), nomenclatura semântica e expressiva, eliminação de duplicação de lógica (DRY), e tratamento robusto e tipado de erros.
- *Racional*: A modularidade e a clareza do código reduzem débito técnico, facilitam a manutenção contínua e garantem que componentes de acessibilidade mantenham consistência em todas as plataformas.

### III. Testabilidade Contínua e Alta Cobertura (Mínimo de 80%)
- **Cultura Test-First e Rigor de Testes**: Regras de negócio e contratos de API DEVEM ser guiados por especificações e testes automatizados.
- **Meta de Cobertura Global**: É OBRIGATÓRIA a cobertura mínima de 80% (linhas e branches) verificada via suíte de testes automatizados no backend e no frontend.
- **Pirâmide de Testes Completa**:
  1. *Testes Unitários*: Cobertura completa de regras de negócios, casos de uso, formatadores e transformações de dados.
  2. *Testes de Componentes/Widgets*: Validação visual e semântica de componentes Flutter, incluindo validação da árvore semântica (`tester.getSemantics()`).
  3. *Testes de Integração e Contrato*: Validação de ponta a ponta dos fluxos críticos de usuário e contratos das APIs Node.js com o banco PostgreSQL.
- **Zero Regressão**: Nenhum Pull Request será aprovado ou integrado se quebrar testes existentes ou se rebaixar o índice de cobertura global para menos de 80%.
- *Racional*: Erros sutis em árvores de acessibilidade ou regras de dados isolam diretamente o usuário com deficiência. Testes rigorosos e automatizados são a única garantia confiável de estabilidade contínua.

### IV. Privacidade por Padrão e Conformidade Rígida com a LGPD (Lei nº 13.709/2018)
- **Privacy by Design e Minimização**: O sistema DEVE coletar e processar unicamente os dados estritamente necessários para a execução dos serviços solicitados pelo usuário.
- **Proteção a Dados Pessoais Sensíveis**: Informações relativas a deficiências, condições de acessibilidade ou saúde são legalmente dados pessoais sensíveis (Art. 5º, II da LGPD). O tratamento EXIGE consentimento explícito, granular e destacado, com gestão simples de revogação pelo titular.
- **Segurança Criptográfica**: Criptografia de ponta a ponta em trânsito (HTTPS / TLS 1.3) e em repouso no PostgreSQL (AES-256 para dados sensíveis e hashes seguros como Argon2/bcrypt para credenciais).
- **Direitos dos Titulares Garantidos**: O sistema DEVE disponibilizar funcionalidades nativas para exportação de dados (portabilidade), correção cadastral, anonimização e exclusão definitiva de conta e dados vinculados ("direito ao esquecimento").
- **Auditoria e Logs Seguros**: Registros de auditoria de consentimento e transações sensíveis DEVEM ser mantidos de forma segura e pseudonimizada, sendo proibido o registro de dados pessoais identificáveis (PII) em logs de depuração.
- *Racional*: Proteger os dados dos usuários é imperativo ético e legal. A conformidade irrestrita com a LGPD assegura a proteção contra sanções legais e consolida a confiança dos usuários.

### V. Consistência Multiplataforma (Flutter) e Paridade por Contêineres (Docker + Node.js + PostgreSQL)
- **Base de Código Unificada (Flutter)**: A experiência do usuário, identidade visual e recursos de acessibilidade DEVEM ser consistentes entre Web, Android e iOS, aproveitando o código compartilhado em Flutter e isolando em adaptadores apenas recursos que dependam de APIs nativas específicas.
- **Conteinerização Completa (Docker)**: O ecossistema backend (API Node.js, banco de dados PostgreSQL e serviços auxiliares) DEVE ser inteiramente orquestrado via `Dockerfile` e `docker-compose.yml`.
- **Paridade entre Ambientes**: O ambiente de desenvolvimento local, a pipeline de Integração Contínua (CI) e os ambientes de homologação/produção DEVEM executar imagens e configurações idênticas, eliminando discrepâncias ambientais.
- **Gerenciamento de Schema por Migrações**: Toda alteração no banco de dados PostgreSQL DEVE ser formalizada através de migrações (migrations) versionadas e auditadas; alterações manuais de schema são estritamente vedadas.
- *Racional*: A contêinerização padronizada garante rápida integração de novos desenvolvedores, estabilidade nos testes automatizados e implantações previsíveis e seguras em produção.

## Stack Tecnológica e Padrões de Engenharia

- **Frontend / Cliente Multiplataforma**: Flutter SDK (Web, Android e iOS) com suporte ativo a acessibilidade nativa, arquitetura orientada a componentes e gerenciamento de estado previsível.
- **Backend / API**: Node.js com TypeScript, adotando princípios de Clean Architecture, validação estrita de esquemas em todas as entradas/saídas e documentação OpenAPI.
- **Banco de Dados**: PostgreSQL com modelagem relacional normalizada, controle de concorrência, migrações versionadas e índices otimizados.
- **Infraestrutura e DevOps**: Docker e Docker Compose para isolamento e orquestração dos serviços de backend; pipelines de CI/CD para validação contínua de lint, formatação, testes e segurança.

## Processo de Desenvolvimento e Quality Gates

- **Quality Gate 1 - Acessibilidade**: Todas as telas e componentes novos ou modificados devem ser validados quanto à semântica de acessibilidade (WCAG 2.1 AA) e testados contra leitores de tela.
- **Quality Gate 2 - Cobertura de Código**: Mínimo de 80% de cobertura de código em suítes automatizadas de testes unitários, de componentes e de integração.
- **Quality Gate 3 - Validação LGPD**: Qualquer funcionalidade que envolva coleta, processamento ou armazenamento de dados pessoais ou sensíveis deve passar por verificação de consentimento, minimização e segurança.
- **Quality Gate 4 - Revisão e Padronização**: Formatação padronizada e linting estrito no Flutter e Node.js sem avisos pendentes (zero warnings). Revisão por pares (Code Review) obrigatória antes de qualquer merge na branch principal.

## Governance

- **Supremacia da Constituição**: Esta Constituição sobrepõe-se a qualquer decisão informal ou preferência pontual. Qualquer especificação técnica, plano de implementação ou Pull Request que conflite com estes princípios será rejeitado.
- **Procedimento de Emenda**: Emendas a esta constituição exigem proposta formal, análise de impacto e plano de migração documentado.
- **Versionamento Semântico**:
  - **MAJOR**: Alterações estruturais que redefinam ou removam princípios fundamentais.
  - **MINOR**: Adição de novos princípios, seções ou diretrizes técnicas materiais.
  - **PATCH**: Refinamentos redacionais, correções tipográficas e esclarecimentos pontuais sem alteração normativa.
- **Conformidade em Runtime e CI**: Todos os gates e verificações desta constituição devem ser integrados aos templates de especificação, planejamento e listas de tarefas do Spec Kit.

**Version**: 1.0.0 | **Ratified**: 2026-11-02 | **Last Amended**: 2026-11-02
