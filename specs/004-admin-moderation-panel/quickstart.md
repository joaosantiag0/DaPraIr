# Quickstart: Painel de Controle Administrativo e Moderação

**Feature Branch**: `004-admin-moderation-panel`  
**Date**: 2026-11-05  
**Spec Reference**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)  

Este guia orienta a inicialização rápida do ambiente de desenvolvimento, execução de migrações no banco de dados PostgreSQL, criação de contas administrativas de teste e validação de ponta a ponta das funcionalidades de moderação.

---

## 1. Pré-Requisitos

- **Docker & Docker Compose** em execução (para PostgreSQL).
- **Node.js 20 LTS** & **npm** instalado.
- **Flutter SDK 3.24+** (compatível com Web, Android e iOS).

---

## 2. Configuração do Backend e Banco de Dados

### 2.1 Subir o Banco de Dados PostgreSQL

Na raiz do repositório:
```bash
docker compose up -d postgres
```

### 2.2 Gerar Cliente Prisma e Executar Migrações

No diretório `backend`:
```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev --name add_admin_moderation_models
```

### 2.3 Criar Usuário Administrador de Teste

Execute o script de seed ou crie um usuário admin via Prisma Studio / Node script:
```bash
npx prisma studio
# Ou via console/seed: crie um usuário com role: "ADMIN" e status: "ACTIVE"
```

### 2.4 Executar o Servidor Backend

```bash
npm run dev
# Servidor disponível em http://localhost:3000
```

---

## 3. Configuração do Frontend Flutter

No diretório `frontend`:
```bash
cd frontend
flutter pub get
```

Executar a aplicação no navegador (Web) ou emulador:
```bash
flutter run -d chrome
```

Para acessar o painel de moderação no app:
1. Autentique-se com credenciais de uma conta com papel `ADMIN` ou `MODERATOR`.
2. Acesse a rota `/admin` ou o menu de opções administrativas no perfil do usuário.

---

## 4. Comandos de Teste Automatizado

### 4.1 Testes no Backend (Vitest)

Executar a suíte de testes unitários e de integração do módulo administrativo com cobertura mínima de 80%:
```bash
cd backend
npm run test:coverage
```

### 4.2 Testes no Frontend (Flutter)

Executar testes de widgets, BLoC e árvore de acessibilidade (`Semantics`):
```bash
cd frontend
flutter test --coverage
```

---

## 5. Exemplos de Chamadas de Teste à API (cURL)

### 5.1 Obter Estatísticas Gerais do Painel

```bash
curl -X GET http://localhost:3000/api/v1/admin/dashboard/stats \
  -H "Authorization: Bearer <ADMIN_JWT_TOKEN>"
```

### 5.2 Ocultar Conteúdo em Cascata (Tópico de Fórum)

```bash
curl -X PATCH http://localhost:3000/api/v1/admin/content/FORUM_TOPIC/<TOPIC_ID>/hide \
  -H "Authorization: Bearer <ADMIN_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Publicação contém desinformação sobre rota acessível e discurso inflamado."}'
```

### 5.3 Aplicar Suspensão Temporária de 7 Dias ao Usuário

```bash
curl -X POST http://localhost:3000/api/v1/admin/users/<USER_ID>/penalties \
  -H "Authorization: Bearer <ADMIN_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"penaltyType": "SUSPENSION_7_DAYS", "reason": "Segunda reincidência de conduta abusiva em debate comunitário."}'
```
