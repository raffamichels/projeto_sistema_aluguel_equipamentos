# 🚀 RentEasy Backend API

Backend completo para a plataforma RentEasy - Sistema de aluguel de equipamentos e ferramentas.

## 📋 Índice

- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Executar o Projeto](#executar-o-projeto)
- [Endpoints da API](#endpoints-da-api)
- [Testes](#testes)
- [Segurança](#segurança)

## 🛠 Tecnologias

- **Node.js** v18+
- **Express.js** - Framework web
- **PostgreSQL** - Banco de dados relacional
- **Sequelize** - ORM
- **JWT** - Autenticação
- **Bcrypt** - Hash de senhas
- **Redis** - Cache (opcional)
- **Express Validator** - Validação de dados

## 📁 Estrutura do Projeto

```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # Configuração do banco de dados
│   ├── controllers/
│   │   └── auth.controller.js   # Controladores de autenticação
│   ├── middlewares/
│   │   ├── auth.js              # Middleware de autenticação
│   │   └── errorHandler.js      # Tratamento de erros
│   ├── models/
│   │   └── User.js              # Model de usuário
│   ├── routes/
│   │   └── auth.routes.js       # Rotas de autenticação
│   ├── utils/
│   │   ├── AppError.js          # Classe de erro customizada
│   │   └── logger.js            # Sistema de logs
│   ├── app.js                   # Configuração do Express
│   └── server.js                # Inicialização do servidor
├── .env.example                 # Exemplo de variáveis de ambiente
├── package.json
└── README.md
```

## 📦 Instalação

### 1. Clone o repositório (ou crie a pasta)

```bash
mkdir renteasy-backend
cd renteasy-backend
```

### 2. Instale as dependências

```bash
npm install
```

### 3. Configure o PostgreSQL

Certifique-se de ter o PostgreSQL instalado e rodando. Crie um banco de dados:

```sql
CREATE DATABASE renteasy_db;
```

## ⚙️ Configuração

### 1. Variáveis de Ambiente

Copie o arquivo `.env.example` para `.env`:

```bash
cp .env.example .env
```

### 2. Configure as variáveis no arquivo `.env`:

```env
# Server
NODE_ENV=development
PORT=5000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=renteasy_db
DB_USER=postgres
DB_PASSWORD=sua_senha_aqui

# JWT
JWT_SECRET=seu_secret_super_seguro_aqui_mude_em_producao
JWT_EXPIRES_IN=7d
```

**IMPORTANTE:** Gere um JWT_SECRET seguro:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

## 🚀 Executar o Projeto

### Desenvolvimento

```bash
npm run dev
```

O servidor estará rodando em: `http://localhost:5000`

### Produção

```bash
npm start
```

## 📚 Endpoints da API

### Base URL
```
http://localhost:5000/api/v1
```

### Autenticação

#### 1. Registrar Usuário
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "name": "João Silva",
  "email": "joao@example.com",
  "password": "Senha123",
  "phone": "(11) 99999-9999",
  "cpf": "123.456.789-00",
  "role": "customer"
}
```

**Resposta (201):**
```json
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "uuid",
      "name": "João Silva",
      "email": "joao@example.com",
      "role": "customer",
      "isActive": true,
      "createdAt": "2025-01-15T10:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 2. Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "joao@example.com",
  "password": "Senha123"
}
```

**Resposta (200):**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 3. Obter Perfil do Usuário (Protegida)
```http
GET /api/v1/auth/me
Authorization: Bearer {token}
```

**Resposta (200):**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "uuid",
      "name": "João Silva",
      "email": "joao@example.com",
      "role": "customer"
    }
  }
}
```

#### 4. Atualizar Perfil (Protegida)
```http
PUT /api/v1/auth/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "João Silva Santos",
  "phone": "(11) 98888-8888",
  "address": {
    "street": "Rua Example, 123",
    "city": "São Paulo",
    "state": "SP",
    "zipCode": "01234-567"
  }
}
```

#### 5. Alterar Senha (Protegida)
```http
PUT /api/v1/auth/change-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "currentPassword": "Senha123",
  "newPassword": "NovaSenha456"
}
```

#### 6. Refresh Token
```http
POST /api/v1/auth/refresh-token
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### 7. Logout (Protegida)
```http
POST /api/v1/auth/logout
Authorization: Bearer {token}
```

### Health Check
```http
GET /health
```

## 🧪 Testes

### Testar com cURL

**Registro:**
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teste User",
    "email": "teste@example.com",
    "password": "Senha123",
    "role": "customer"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "Senha123"
  }'
```

### Testar com Postman/Insomnia

Importe a coleção com os endpoints acima ou teste manualmente.

## 🔒 Segurança

- ✅ Passwords hasheados com bcrypt (salt rounds: 10)
- ✅ JWT para autenticação stateless
- ✅ Helmet para headers de segurança
- ✅ CORS configurado
- ✅ Rate limiting (100 requisições/15min)
- ✅ Validação de inputs com express-validator
- ✅ Proteção contra SQL Injection (Sequelize ORM)
- ✅ XSS protection

## 📝 Validações

### Registro:
- Nome: 2-100 caracteres
- Email: formato válido
- Senha: mínimo 6 caracteres, deve conter maiúscula, minúscula e número
- CPF: formato XXX.XXX.XXX-XX (opcional)
- Role: 'customer' ou 'owner'

### Roles:
- **customer**: Usuário que aluga equipamentos
- **owner**: Proprietário que disponibiliza equipamentos
- **admin**: Administrador do sistema (criado manualmente)

## 🔄 Próximos Passos

- [ ] Implementar recuperação de senha por email
- [ ] Adicionar verificação de email
- [ ] Implementar sistema de produtos/equipamentos
- [ ] Sistema de reservas/aluguéis
- [ ] Integração de pagamentos
- [ ] Sistema de avaliações
- [ ] Upload de imagens
- [ ] Geolocalização
- [ ] Notificações em tempo real

## 📞 Suporte

Para dúvidas ou problemas:
- Email: suporte@renteasy.com
- GitHub Issues: [link do repositório]

---

**Desenvolvido com ❤️ pela equipe RentEasy**