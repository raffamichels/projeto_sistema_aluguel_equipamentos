#  RentEasy: Sistema de Gerenciamento de Aluguel de Equipamentos

O RentEasy é uma solução robusta para gerenciamento de locação, manutenção e estoque de equipamentos. O projeto foca em integridade de dados (utilizando SGBD SQL) e automação de processos críticos através de objetos de banco de dados, garantindo eficiência operacional e dados confiáveis para análise de negócio.

##  Escopo e Tecnologias

Este projeto abrange o **back-end de banco de dados** e a **estrutura de interface**, seguindo os padrões da Terceira Forma Normal (3NF) para otimização de dados.

| Categoria | Detalhes |
| :--- | :--- |
| **SGBD Principal** | Microsoft SQL Server (Linguagem T-SQL) |
| **Modelagem** | 12 Tabelas, Chaves Primárias Compostas, Integridade Referencial (FKs). |
| **Lógica de Negócios** | Stored Procedures, Funções e Triggers para automação de fluxo. |
| **Performance** | Índices Não Clusterizados (NC) aplicados em chaves estrangeiras e colunas de consulta frequente. |
| **Templates UI** | HTML (Estrutura de *front-end* para interação com as rotas de *back-end*). |

---

##  Estrutura do Banco de Dados

O modelo de dados é centralizado nas entidades **ALUGUEL**, **EQUIPAMENTO** e **CLIENTES**, com uma tabela de relacionamento N:N (**ALUGUEL_ITEM**).



###  Objetos de Lógica de Negócio

A automação de processos é implementada através dos seguintes objetos:

| Objeto | Tipo | Funcionalidade |
| :--- | :--- | :--- |
| **`TRG_Equipamento_Em_Manutencao`** | Trigger | Atualiza o `status` do equipamento para 'Em Manutenção' automaticamente quando um novo registro é inserido na tabela `MANUTENCAO`. |
| **`fn_CalcularValorRealAluguel`** | Function | Calcula o valor real final do aluguel (valor\_diaria \* dias decorridos) para fins de conferência e auditoria. |
| **`SP_FinalizarAluguel`** | Stored Procedure | Processa a devolução: calcula multa por atraso, atualiza a tabela `ALUGUEL`, registra a multa pendente (tabela `MULTAS`), e libera o `status` do(s) equipamento(s) no `ESTOQUE`. |

---

##  Guia de Execução

Para configurar e rodar a aplicação, execute os scripts SQL na ordem exata para garantir que as dependências sejam respeitadas.

| Passo | Script SQL | Descrição |
| :--- | :--- | :--- |
| **1. Estrutura** | `DDL_CreateTables.sql` | Cria todas as 12 tabelas, Chaves Primárias e Estrangeiras. |
| **2. Dados** | `DML_InsertData.sql` | Insere dados de exemplo para testes e demonstração. |
| **3. Lógica** | `Objetos_Trigger_Indices.sql` | Cria o **TRIGGER** de Manutenção. |
| **4. Lógica** | `Objetos_Function_Indices.sql` | Cria a **FUNCTION** de cálculo de valor real. |
| **5. Lógica** | `Objetos_SP_Function.sql` | Cria a **STORED PROCEDURE** de finalização de aluguel. |
| **6. Otimização** | `DDL_indexes.sql` | Cria índices não clusterizados para otimizar a performance das consultas. |

---

##  Estrutura da Interface (Templates HTML)

Os seguintes templates representam as telas de interação do usuário com o sistema, que deverão ser conectadas aos endpoints do *back-end* (ex: Flask, Express) para interagir com os objetos SQL.

| Template HTML | Propósito Funcional |
| :--- | :--- |
| `index.html` | Tela inicial e *dashboard* de resumo. |
| `equipamentos_disponiveis.html` | Visualização rápida de todos os itens prontos para locação. |
| `alugueis_ativos.html` | Visualização de todas as locações que ainda não foram devolvidas. |
| **`operacao_finalizar.html`** | Formulário de entrada de dados para acionar a **`SP_FinalizarAluguel`**. |
| **`operacao_manutencao.html`** | Formulário de entrada de dados para registrar uma nova manutenção, ativando o **TRIGGER**. |

---

##  Análise de Negócio (KPIs Suportados)

O modelo RentEasy foi construído para responder a perguntas de negócio complexas, utilizando os dados e a lógica implementada:

1.  **Receita Líquida Total:** Cálculo de Receita de Aluguel + Multas Pagas.
2.  **ROI por Categoria:** Relação entre Receita de Aluguel e Custos de Manutenção por Categoria.
3.  **Clientes de Alto Risco:** Identificação de clientes com histórico de multas E aluguéis ativos com atraso.
4.  **Duração Média de Aluguéis:** Estatísticas sobre a real duração das locações para planejamento logístico.
5.  **Performance de Vendas:** Receita total gerada por cada funcionário vendedor.

---

##  Contribuição e Próximos Passos

Sugestões e melhorias são bem-vindas. O projeto pode ser expandido com:

* Implementação de um **back-end** (ex: Python/Flask) para roteamento e conexão com o SQL Server.
* Criação de **Views** para simplificar as consultas de KPIs.
* Adição de *front-end* **CSS/JS** para dar vida aos templates HTML.
