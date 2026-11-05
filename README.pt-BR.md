# DáPraIr? — Plataforma Social e Avaliações de Acessibilidade Física

[![🇺🇸 English](https://img.shields.io/badge/Language-English-blue?style=flat-square)](README.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-v3.24%2B-02569B?logo=flutter&style=flat-square)](https://flutter.dev)
[![Fastify](https://img.shields.io/badge/Fastify-v4-black?logo=fastify&style=flat-square)](https://fastify.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript&style=flat-square)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16%20%2B%20PostGIS-336791?logo=postgresql&style=flat-square)](https://www.postgresql.org)
[![WCAG](https://img.shields.io/badge/Accessibility-WCAG%202.1%20AA%2FAAA-green?style=flat-square)](https://www.w3.org/WAI/standards-guidelines/wcag/)

> **Read this in other languages:**  
> 🇺🇸 [English version](README.md) | 🇧🇷 **Português (Brasil)**

O **DáPraIr?** é um ecossistema multiplataforma (Mobile, Web e Desktop) e colaborativo dedicado a mapear, avaliar e compartilhar condições reais de acessibilidade física em estabelecimentos, espaços urbanos e eventos comunitários.

Inspirado nas diretrizes da norma técnica brasileira **ABNT NBR 9050** e nos princípios internacionais de acessibilidade digital **WCAG 2.1 (níveis AA e AAA)**, o projeto combina crowdsourcing cidadão, recursos sociais e conformidade estrita com a **LGPD (Lei Geral de Proteção de Dados)**.

---

## ✨ Principais Funcionalidades

### ♿ Avaliações Cidadãs de Acessibilidade
- Avaliação detalhada de locais com base em **7 critérios padronizados** da ABNT NBR 9050.
- Suporte a fotos de acessibilidade com **audiodescrição obrigatória (`alt_text`)** para leitores de tela.
- Salvamento e sincronização offline de rascunhos de avaliação (`SharedPreferences`).

### 🗺️ Integração Geográfica Inteligente com Google Places
- Busca com limitação de cota de API e fallback em banco de dados local com extensão geoespacial **PostGIS**.
- Cache de consultas com validade de 24 horas para economia e resiliência.
- Agrupamento em grade geoespacial de 500m para sincronização de locais próximos.

### 💬 Fórum Comunitário e Debates Categorizados
- Discussões públicas, comunitárias e privadas estruturadas por categorias temáticas.
- Suporte a réplicas aninhadas e subthreads com colapso expansível.
- Selo de edição transparente `(editado)` e contagem em tempo real de curtidas e respostas.
- Retenção do estado e cache inteligente entre navegações de tela.

### 🤝 Conexões Sociais e Chat Direto
- Lista de amigos mútuos, solicitações de amizade e sugestões de membros com rotas em comum.
- Mensagens diretas em tempo real com criptografia ponta a ponta e modo visitante amigável.

### 🛡️ Moderação Colaborativa e Quarentena Automática
- Sistema de denúncias anônimas em avaliações, debates e comentários.
- **Quarentena automática**: conteúdos com 3 ou mais denúncias distintas saem imediatamente do ar até decisão da moderação.
- Alerta explícito de regras na primeira publicação do usuário: incentivo à denúncia cidadã e aviso de que conteúdos contendo extremismo político e religioso devem ser evitados e poderão ser removidos.

### 🔒 Privacidade e Conformidade LGPD
- Localização exata e dados sensíveis de saúde criptografados com **AES-256-GCM**.
- Hashes de senhas com o algoritmo padrão de segurança **Argon2id**.
- Pseudonimização de IPs em registros de consentimento com **SHA-256**.
- Painel de Governança de Dados com suporte a **Portabilidade** e **Direito ao Esquecimento**.

---

## ♿ Critérios Padronizados (ABNT NBR 9050)

1. **Rampa de Acesso ou Entrada em Nível** (`ENTRANCE_RAMP_LEVEL`)
2. **Elevador ou Plataforma Elevatória** (`ELEVATOR_LIFT`)
3. **Banheiro Adaptado** (`ADAPTED_BATHROOM`)
4. **Espaço de Circulação e Manobra** (`MANEUVERING_SPACE`)
5. **Assentos e Mesas Acessíveis** (`ADAPTED_SEATING`)
6. **Vagas Reservadas** (`ACCESSIBLE_PARKING`)
7. **Atendimento Inclusivo** (`INCLUSIVE_SERVICE`)

---

## 🏗️ Arquitetura e Tecnologias

- **Frontend**: Flutter 3.24+ (Dart 3.5+), BLoC / Cubit, Clean Architecture, Design Responsivo (`NavigationRail` para desktop/tablet e `NavigationBar` para mobile).
- **Backend**: Node.js 20+, Fastify, TypeScript, Prisma ORM, Zod.
- **Banco de Dados**: PostgreSQL 16 com extensão espacial PostGIS.
- **Infraestrutura**: Docker & Docker Compose, arquitetura de microsserviços conteinerizada.

---

## 🚀 Como Executar Localmente

### 1. Pré-requisitos
- [Node.js](https://nodejs.org/) v20+ e `npm`
- [Docker & Docker Compose](https://www.docker.com/)
- [Flutter SDK](https://flutter.dev) v3.24+

---

### 2. Inicialização Rápida com Docker (Recomendado)
Inicie o banco de dados PostGIS e o servidor backend com um único comando:

```bash
docker compose up -d --build
```

O container aplicará as migrações do banco e executará o seed inicial de dados automaticamente.

- **API REST**: `http://localhost:3333`
- **Swagger / OpenAPI**: `http://localhost:3333/docs`
- **PostgreSQL / PostGIS**: porta `5433` (mapeada para a porta interna `5432`)

---

### 3. Backend Local (Sem Docker)
```bash
cd backend
npm install
npx prisma db push
npx tsx prisma/seed.ts
npm run dev
```

Executar testes com cobertura mínima de 80%:
```bash
npm run test:coverage
```

---

### 4. Frontend Flutter
```bash
cd frontend
flutter pub get

# Executar na Web
flutter run -d chrome

# Executar no macOS Desktop
flutter run -d macos

# Executar em emulador móvel ou dispositivo físico
flutter run
```

Executar todos os testes de widget e unidade com auditoria de acessibilidade:
```bash
flutter test --coverage
```

---

## 📜 Licença e Atribuição de Créditos

Este projeto está licenciado sob os termos da licença **MIT** — consulte o arquivo [LICENSE](LICENSE) para detalhes completos.

### ⚠️ Requisito de Atribuição e Créditos
Conforme especificado na licença MIT, **é obrigatório manter os avisos de direitos autorais originais e dar os devidos créditos** caso você utilize, faça fork, modifique ou distribua este software ou trechos dele em projetos derivados:

- **Autor Original**: [João Santiago](https://github.com/joaosantiag0)
- **Repositório**: [https://github.com/joaosantiag0/daPraIr](https://github.com/joaosantiag0/daPraIr)
- **Projeto**: DáPraIr? — Plataforma Social e Avaliações de Acessibilidade Física
