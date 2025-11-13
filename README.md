# RentEasy

Backend - Sistema de aluguel de equipamentos e ferramentas.

## Índice

- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)

## Tecnologias

- **Node.js** backend
- **Express.js** - Framework web
- **SQLServer** - Banco de dados relacional

## Estrutura do Projeto

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
