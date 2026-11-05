# Quickstart: Espaço de Debate e Fórum de Tópicos Categorizados

**Feature Branch**: `002-forum-topics-discussions`  
**Date**: 2026-11-04  

Este guia detalha o processo de inicialização, execução local, migrações de banco de dados e testes da funcionalidade de fórum e debates.

---

## 1. Pré-Requisitos

- **Docker & Docker Compose** (para PostgreSQL 16 + PostGIS)
- **Node.js 20 LTS** & **npm**
- **Flutter SDK 3.24+** & **Dart 3.5+**

---

## 2. Inicialização do Ambiente

### 2.1. Subir Infraestrutura Docker
Na raiz do repositório:
```bash
docker compose up -d postgres minio
```

### 2.2. Backend (Node.js + Prisma)
Acesse a pasta do backend e instale as dependências:
```bash
cd backend
npm install
```

Gere o cliente Prisma e execute as migrações:
```bash
npm run prisma:generate
npm run prisma:migrate
```

Inicie o servidor de desenvolvimento:
```bash
npm run dev
```
O servidor estará disponível em `http://localhost:3000` com documentação interativa Swagger em `http://localhost:3000/docs`.

### 2.3. Frontend (Flutter)
Em outro terminal, acesse a pasta do frontend:
```bash
cd frontend
flutter pub get
flutter run -d chrome # ou android/ios
```

---

## 3. Execução de Testes Automatizados

### 3.1. Testes do Backend (Vitest)
```bash
cd backend
# Executar todos os testes com cobertura
npm run test:coverage
```
*Meta de cobertura mínima exigida pela Constituição: >= 80%*.

### 3.2. Testes do Frontend (Flutter)
```bash
cd frontend
# Executar testes unitários e de widgets com validação de semântica WCAG
flutter test --coverage
```

---

## 4. Exemplos de Uso da API (cURL)

### 4.1. Listar Categorias do Fórum (Acesso Público / Visitante)
```bash
curl -X GET http://localhost:3000/api/v1/forum/categories
```

### 4.2. Listar Tópicos Públicos de uma Categoria (Visitante Anônimo)
```bash
curl -X GET "http://localhost:3000/api/v1/forum/topics?category_id=<CATEGORY_UUID>&sort_by=recent"
```

### 4.3. Criar um Novo Tópico (Usuário Autenticado)
```bash
curl -X POST http://localhost:3000/api/v1/forum/topics \
  -H "Authorization: Bearer <SEU_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "<CATEGORY_UUID>",
    "title": "Acessibilidade no transporte público municipal",
    "content": "Gostaria de discutir sobre as rampas automáticas dos novos ônibus municipais...",
    "visibility": "PUBLIC"
  }'
```

### 4.4. Responder a um Tópico ou Comentário (Subthread)
```bash
curl -X POST http://localhost:3000/api/v1/forum/topics/<TOPIC_UUID>/comments \
  -H "Authorization: Bearer <SEU_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "parent_id": null,
    "content": "Concordo plenamente. Na linha 102 também tivemos problemas na semana passada.",
    "visibility": "PUBLIC"
  }'
```

### 4.5. Curtir / Descurtir um Tópico
```bash
curl -X POST http://localhost:3000/api/v1/forum/topics/<TOPIC_UUID>/like \
  -H "Authorization: Bearer <SEU_JWT_TOKEN>"
```
