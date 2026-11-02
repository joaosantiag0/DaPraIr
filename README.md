# DáPraIr? — Plataforma Social e Avaliações de Acessibilidade Física

O **DáPraIr?** é um ecossistema multiplataforma (Web & Mobile) e colaborativo dedicado a mapear, avaliar e compartilhar condições reais de acessibilidade física em estabelecimentos, espaços urbanos e eventos comunitários.

---

## 🚀 Como Executar o Projeto Localmente

### 1. Pré-requisitos
- **Node.js**: v20+ e npm
- **Docker & Docker Compose** (para PostgreSQL 16 + PostGIS)
- **Flutter SDK**: v3.24+

---

### 2. Subir o Banco de Dados PostGIS
```bash
docker compose up -d
```
> O banco de dados PostGIS estará disponível na porta `5433` (mapeada para `5432` no container).

---

### 3. Configurar e Iniciar o Backend
```bash
cd backend
npm install
npx prisma db push
npx tsx prisma/seed.ts
npm run dev
```
- API disponível em: `http://localhost:3333`
- Documentação interativa OpenAPI/Swagger: `http://localhost:3333/docs`

---

### 4. Executar os Testes do Backend (com cobertura >= 80%)
```bash
cd backend
npm run test:coverage
```

---

### 5. Configurar e Iniciar o Frontend Flutter
```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome # Para web
# ou: flutter run -d macos / flutter run
```

---

### 6. Executar os Testes do Frontend e Auditoria WCAG
```bash
cd frontend
flutter test --coverage
```

---

## ♿ Critérios Padronizados de Acessibilidade

O DáPraIr? baseia-se na norma técnica **ABNT NBR 9050** e avalia 7 critérios fundamentais:
1. **Rampa de Acesso ou Entrada em Nível** (`rampa_acesso`)
2. **Portas e Vãos Largos** (`porta_larga`)
3. **Banheiro Acessível Adaptado** (`banheiro_adaptado`)
4. **Circulação Interna Desobstruída** (`circulacao_interna`)
5. **Vagas de Estacionamento Reservadas PCD** (`vagas_pcd`)
6. **Sinalização Visual e Tátil** (`sinalizacao_tatil_visual`)
7. **Atendimento Prioritário e Cordialidade** (`atendimento_capacitado`)

---

## 🔒 Conformidade LGPD e Privacidade
- Dados de saúde e necessidades de apoio são armazenados com criptografia simétrica **AES-256-GCM**.
- Hashes de senhas utilizam o algoritmo **Argon2id**.
- IPs de consentimento são pseudonimizados com **SHA-256**.
- Suporte total aos direitos do titular: **Portabilidade** e **Direito ao Esquecimento**.

---

## 🛡️ Moderação por Quarentena Automática
- Conteúdos com **1 a 2 denúncias distintas** recebem o selo público de *"Sob análise da moderação"*.
- Conteúdos com **3 ou mais denúncias distintas** entram imediatamente em **QUARENTENA** e são ocultados automaticamente de buscas públicas e feeds até decisão da moderação humana.
