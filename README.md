# RentEasy

Backend - Sistema de aluguel de equipamentos e ferramentas.

## Índice

- [Status do Projeto](#status-do-projeto)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Modelagem do Banco de Dados](#modelagem-do-banco-de-dados)
- [Status da Equipe (Milestone 2)](#status-da-equipe-milestone-2)
- [Fluxo de Trabalho](#fluxo-de-trabalho)

## Status do Projeto

O projeto concluiu a fase de **Modelagem (Milestone 1)** e iniciou a **Implementação SQL (Milestone 2)**. A fusão do script DDL (Issue #21) na branch `main` é o próximo passo crítico para desbloquear as tarefas sequenciais.

| Milestone | Foco Principal | Status |
| :--- | :--- | :--- |
| **M1: Documentação** | Modelagem Conceitual, Lógica e Dicionário de Dados. | **✅ CONCLUÍDA** |
| **M2: Implementação** | Scripts SQL DDL, DML e Objetos de Banco. | **▶️ EM ANDAMENTO** |
| **M3: Integração** | Desenvolvimento da API e testes. | 🕒 PENDENTE |

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
## Modelagem do Banco de Dados (M1 Concluída)

A estrutura do banco de dados relacional (12 entidades) foi definida na Milestone 1. Os scripts de implementação estão na pasta `/scripts`.

| Artefato | Status | Caminho Sugerido |
| :--- | :--- | :--- |
| **Dicionário de Dados** | Concluído | `[modelagem/Dicionario_de_Dados.xlsx]` |
| **DDL (Issue #21)** | **PR Pendente** | `[scripts/DDL_CreateTables.sql]` |

## Status da Equipe (Milestone 2)

O trabalho da M2 é sequencial e depende do DDL (Issue #21) ser mesclado.

| Issue | Descrição | Responsável | Status Atual | Observações |
| :--- | :--- | :--- | :--- | :--- |
| **#21** | **Script DDL** (Estrutura) | Kamily | **PR Pendente** | Necessita de revisão do Andre |
| **#22** | Script DML (Dados) | Kaua | Pendente | **Bloqueada:** Aguardando o merge da Issue #21. |
| **#26** | Revisão do DDL/Otimização | Andre | Pendente | **Ação Imediata:** Deve revisar o PR da Issue #21. |
| *[Outra Issue]* | *[Descrição]* | *[Integrantes Pendentes]* | *Não Concluída* | *[Adicionar as duas issues que faltam]* |

## Fluxo de Trabalho

* **Base:** Puxe sempre o último código da branch **`main`**.
* **Branching:** Utilize o modelo `feature/issue-XX-descricao`.
* **Merge:** O merge para a `main` deve ser feito via **Pull Request (PR)** após a revisão e aprovação.
