-- Projeto: Sistema de Aluguel de Equipamentos
-- SCRIPT DE OTIMIZAÇÃO (ISSUE #26)
-- Autor: Pessoa F
-- Descrição: Criação de Índices Non-Clustered para performance
-- Justificativa: Otimização de SARGs (Argumentos de Busca) e Joins
-- 

-- 1. Otimização de CLIENTES (Busca por endereço e nome)
CREATE NONCLUSTERED INDEX IX_CLIENTES_ENDERECO ON CLIENTES (endereco_id);
CREATE NONCLUSTERED INDEX IX_CLIENTES_NOME ON CLIENTES (Nome);

-- 2. Otimização de EQUIPAMENTOS (Agrupar por categoria)
CREATE NONCLUSTERED INDEX IX_EQUIPAMENTO_CATEGORIA ON EQUIPAMENTO (categoria_id);

-- 3. Otimização de ESTOQUE (Verificar disponibilidade)
CREATE NONCLUSTERED INDEX IX_ESTOQUE_EQUIPAMENTO ON ESTOQUE (equipamento_id);

-- 4. Otimização de ALUGUEL (Tabela Transacional - FKs e Datas)
CREATE NONCLUSTERED INDEX IX_ALUGUEL_CLIENTE ON ALUGUEL (cliente_id);
CREATE NONCLUSTERED INDEX IX_ALUGUEL_FUNCIONARIO ON ALUGUEL (funcionario_id);
CREATE NONCLUSTERED INDEX IX_ALUGUEL_DATAS ON ALUGUEL (data_inicio, data_devolucao);

-- 5. Otimização de ALUGUEL_ITEM (Detalhes do aluguel)
CREATE NONCLUSTERED INDEX IX_ALUGUELITEM_EQUIPAMENTO ON ALUGUEL_ITEM (equipamento_id);

-- 6. Otimização de PAGAMENTOS (Rastreio financeiro)
CREATE NONCLUSTERED INDEX IX_PAGAMENTOS_ALUGUEL ON PAGAMENTOS (aluguel_id);

-- 7. Otimização de MANUTENCAO (Histórico)
CREATE NONCLUSTERED INDEX IX_MANUTENCAO_EQUIPAMENTO ON MANUTENCAO (equipamento_id);
CREATE NONCLUSTERED INDEX IX_MANUTENCAO_FORNECEDOR ON MANUTENCAO (fornecedor_id);

-- 8. Otimização de MULTAS (Controle de infrações)
CREATE NONCLUSTERED INDEX IX_MULTAS_ALUGUEL ON MULTAS (aluguel_id);