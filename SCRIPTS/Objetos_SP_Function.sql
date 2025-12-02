-- STORED PROCEDURE: SP_FinalizarAluguel

-- OBJETIVO:
-- Automatizar o processo completo de finalização de um aluguel, incluindo:
-- 1. Cálculo automático de multas por atraso na devolução
-- 2. Registro da multa na tabela MULTAS
-- 3. Atualização da data de devolução do aluguel
-- 4. Liberação dos equipamentos no estoque (status 'Disponível')
-- 5. Atualização das quantidades disponíveis no estoque
-- 6. Validações de integridade e regras de negócio

-- JUSTIFICATIVA DE USO:
-- 1. INTEGRIDADE TRANSACIONAL
--    - Todas as operações são executadas em uma única transação
--    - Se qualquer etapa falhar, todas as alterações são revertidas (ROLLBACK)
--    - Evita estados inconsistentes (ex: aluguel finalizado mas equipamento ainda 'Em Uso')
--
-- 2. AUTOMATIZAÇÃO DE LÓGICA COMPLEXA
--    - Calcula automaticamente multas por atraso baseado em regras de negócio
--    - Atualiza múltiplas tabelas (ALUGUEL, EQUIPAMENTO, ESTOQUE, MULTAS)
--    - Reduz erros humanos em processos manuais
--
-- 3. PERFORMANCE
--    - Plano de execução é compilado e cacheado pelo SQL Server
--    - Mais rápido que executar comandos SQL separados da aplicação
--
-- 4. SEGURANÇA
--    - Centraliza a lógica de negócio no banco de dados
--    - Valida dados antes de processar
--
-- 5. MANUTENIBILIDADE
--    - Não requer atualização da aplicação para mudanças na lógica
--    - Facilita versionamento e controle de mudanças
--    - Documentação centralizada
--
-- 6. AUDITORIA E RASTREABILIDADE
--    - Registra todas as multas aplicadas
--    - Mantém histórico de operações
--    - Facilita relatórios e análises
--
-- 7. REUTILIZAÇÃO
--    - Interface padronizada para finalização de aluguéis
--    - Evita duplicação de código em múltiplos sistemas

GO

-- Remove a procedure se já existir
IF OBJECT_ID('dbo.SP_FinalizarAluguel', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_FinalizarAluguel;
GO

CREATE PROCEDURE SP_FinalizarAluguel
    @p_AluguelID INT,
    @p_DataDevolucao DATETIME = NULL,
    @p_FuncionarioID INT,
    @p_ValorMulta DECIMAL(10,2) OUTPUT,
    @p_Mensagem VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_DataInicio DATE;
    DECLARE @v_DataDevolucaoEsperada DATE;
    DECLARE @v_DiasAluguel INT;
    DECLARE @v_DiasAtraso INT;
    DECLARE @v_ValorTotalOriginal DECIMAL(10,2);
    DECLARE @v_StatusAtual VARCHAR(20);
    DECLARE @v_ClienteID INT;
    DECLARE @v_MultaPorDia DECIMAL(10,2) = 15.00; -- R$ 15,00 por dia de atraso
    DECLARE @v_PercentualMulta DECIMAL(5,2) = 0.10; -- 10% do valor total
    DECLARE @v_ValorMultaCalculada DECIMAL(10,2);
    DECLARE @v_DescricaoMulta VARCHAR(255);
    DECLARE @v_EquipamentoID INT;
    DECLARE @v_Quantidade SMALLINT;
    DECLARE @v_QuantAtual SMALLINT;
    DECLARE @v_NumeroSerie VARCHAR(50);
    DECLARE @v_NomeEquipamento VARCHAR(100);
    DECLARE @v_ItensProcessados INT = 0;
    
    -- Variáveis para cursor
    DECLARE @v_CursorAberto BIT = 0;
    
    BEGIN TRY
        -- Inicia a transação
        BEGIN TRANSACTION;
        
        -- VALIDAÇÃO 1: Verificar se o aluguel existe
        SELECT 
            @v_DataInicio = a.data_inicio,
            @v_DataDevolucaoEsperada = DATEADD(DAY, 7, a.data_inicio),
            @v_ValorTotalOriginal = a.valor_total,
            @v_ClienteID = a.cliente_id,
            @v_StatusAtual = CASE 
                WHEN a.data_devolucao IS NULL THEN 'Ativo'
                ELSE 'Finalizado'
            END
        FROM ALUGUEL a
        WHERE a.aluguel_id = @p_AluguelID;
        
        -- Verifica se encontrou o aluguel
        IF @v_ClienteID IS NULL
        BEGIN
            SET @p_Mensagem = 'ERRO: Aluguel não encontrado (ID: ' + CAST(@p_AluguelID AS VARCHAR) + ')';
            SET @p_ValorMulta = 0.00;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- VALIDAÇÃO 2: Verificar se aluguel já foi finalizado
        IF @v_StatusAtual = 'Finalizado'
        BEGIN
            SET @p_Mensagem = 'ERRO: Aluguel já está finalizado (ID: ' + CAST(@p_AluguelID AS VARCHAR) + ')';
            SET @p_ValorMulta = 0.00;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- VALIDAÇÃO 3: Definir data de devolução
        IF @p_DataDevolucao IS NULL
        BEGIN
            SET @p_DataDevolucao = GETDATE();
        END
        
        SET @v_DiasAluguel = DATEDIFF(DAY, @v_DataInicio, @p_DataDevolucao);
        
        -- Se foi alugado por mais de 7 dias, considera a data atual como esperada
        IF @v_DiasAluguel > 30
        BEGIN
            SET @v_DataDevolucaoEsperada = DATEADD(DAY, 30, @v_DataInicio);
        END
        ELSE IF @v_DiasAluguel > 7
        BEGIN
            SET @v_DataDevolucaoEsperada = DATEADD(DAY, @v_DiasAluguel, @v_DataInicio);
        END
        
        -- CÁLCULO DA MULTA POR ATRASO
        SET @v_DiasAtraso = DATEDIFF(DAY, @v_DataDevolucaoEsperada, @p_DataDevolucao);
        
        IF @v_DiasAtraso > 0
        BEGIN
            -- Multa = (Valor fixo por dia + Percentual do valor total) * Dias de atraso
            SET @v_ValorMultaCalculada = (@v_MultaPorDia + (@v_ValorTotalOriginal * @v_PercentualMulta)) * @v_DiasAtraso;
            
            -- Descrição da multa
            SET @v_DescricaoMulta = 'Multa por atraso de ' + CAST(@v_DiasAtraso AS VARCHAR) + 
                                   ' dia(s) na devolução do equipamento. ' +
                                   'Data prevista: ' + CONVERT(VARCHAR, @v_DataDevolucaoEsperada, 103) + 
                                   '. Data devolução: ' + CONVERT(VARCHAR, @p_DataDevolucao, 103) + '.';
        END
        ELSE
        BEGIN
            SET @v_ValorMultaCalculada = 0.00;
            SET @v_DescricaoMulta = NULL;
        END
        
        SET @p_ValorMulta = @v_ValorMultaCalculada;
        
        -- ATUALIZAÇÃO 1: Finalizar o aluguel
        UPDATE ALUGUEL
        SET 
            data_devolucao = @p_DataDevolucao,
            valor_total = valor_total + @v_ValorMultaCalculada
        WHERE aluguel_id = @p_AluguelID;
        
        -- REGISTRO 1: Inserir multa (se houver)
        IF @v_ValorMultaCalculada > 0
        BEGIN
            INSERT INTO MULTAS (
                aluguel_id,
                valor_multa,
                descricao,
                dt_multa,
                status_pagamento
            ) VALUES (
                @p_AluguelID,
                @v_ValorMultaCalculada,
                @v_DescricaoMulta,
                GETDATE(),
                'Pendente'
            );
        END
        
        -- ATUALIZAÇÃO 2: Liberar equipamentos no estoque
        DECLARE cursor_itens CURSOR FOR
            SELECT 
                ai.equipamento_id,
                ai.quantidade
            FROM ALUGUEL_ITEM ai
            WHERE ai.aluguel_id = @p_AluguelID;
        
        OPEN cursor_itens;
        SET @v_CursorAberto = 1;
        
        FETCH NEXT FROM cursor_itens INTO @v_EquipamentoID, @v_Quantidade;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Buscando informações do equipamento
            SELECT 
                @v_NumeroSerie = numero_serie,
                @v_NomeEquipamento = nome
            FROM EQUIPAMENTO
            WHERE equipamento_id = @v_EquipamentoID;
            
            -- Atualiza status do equipamento para Disponível
            UPDATE EQUIPAMENTO
            SET status = 'Disponível'
            WHERE equipamento_id = @v_EquipamentoID;
            
            -- Atualiza quantidade disponível no estoque
            UPDATE ESTOQUE
            SET 
                quant_disponivel = quant_disponivel + @v_Quantidade,
                data_revisao = CAST(GETDATE() AS DATE)
            WHERE equipamento_id = @v_EquipamentoID;
            
            -- Incrementa contador de itens processados
            SET @v_ItensProcessados = @v_ItensProcessados + 1;
            
            FETCH NEXT FROM cursor_itens INTO @v_EquipamentoID, @v_Quantidade;
        END
        
        CLOSE cursor_itens;
        DEALLOCATE cursor_itens;
        SET @v_CursorAberto = 0;
        
        -- VALIDAÇÃO 4: Verificar se processou algum item
        IF @v_ItensProcessados = 0
        BEGIN
            SET @p_Mensagem = 'AVISO: Aluguel finalizado, mas nenhum item foi encontrado para liberar no estoque.';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- COMMIT DA TRANSAÇÃO
        COMMIT TRANSACTION;
        -- Mensagem de sucesso
        IF @v_DiasAtraso > 0
        BEGIN
            SET @p_Mensagem = 'Aluguel ID ' + CAST(@p_AluguelID AS VARCHAR) + ' finalizado com sucesso! ' +
                             'Atraso de ' + CAST(@v_DiasAtraso AS VARCHAR) + ' dia(s). ' +
                             'Multa aplicada: R$ ' + CAST(@v_ValorMultaCalculada AS VARCHAR(10)) + '. ' +
                             CAST(@v_ItensProcessados AS VARCHAR) + ' equipamento(s) liberado(s) no estoque.';
        END
        ELSE
        BEGIN
            SET @p_Mensagem = 'Aluguel ID ' + CAST(@p_AluguelID AS VARCHAR) + ' finalizado com sucesso! ' +
                             'Devolução no prazo. ' +
                             CAST(@v_ItensProcessados AS VARCHAR) + ' equipamento(s) liberado(s) no estoque.';
        END
        
    END TRY
    BEGIN CATCH
        -- Em caso de erro, desfaz todas as operações
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        IF @v_CursorAberto = 1
        BEGIN
            CLOSE cursor_itens;
            DEALLOCATE cursor_itens;
        END
        
        -- Capturando informações do erro
        SET @p_Mensagem = 'ERRO: ' + ERROR_MESSAGE() + 
                         ' (Linha: ' + CAST(ERROR_LINE() AS VARCHAR) + ')';
        SET @p_ValorMulta = 0.00;
    END CATCH
END;
GO


-- EXEMPLOS DE USO DA STORED PROCEDURE


-- Exemplo 1: Finalizar aluguel usando data atual (sem atraso)
DECLARE @multa DECIMAL(10,2);
DECLARE @msg VARCHAR(500);

EXEC SP_FinalizarAluguel
    @p_AluguelID = 3,           -- ID do aluguel em aberto
    @p_DataDevolucao = NULL,    -- NULL = usa data atual
    @p_FuncionarioID = 2,       -- ID do funcionário
    @p_ValorMulta = @multa OUTPUT,
    @p_Mensagem = @msg OUTPUT;

SELECT @multa AS ValorMulta, @msg AS Mensagem;
GO

-- Exemplo 2: Finalizar aluguel com data específica (com possível atraso)
DECLARE @multa DECIMAL(10,2);
DECLARE @msg VARCHAR(500);

EXEC SP_FinalizarAluguel
    @p_AluguelID = 6,
    @p_DataDevolucao = '2025-12-05',
    @p_FuncionarioID = 5,
    @p_ValorMulta = @multa OUTPUT,
    @p_Mensagem = @msg OUTPUT;

SELECT @multa AS ValorMulta, @msg AS Mensagem;
GO

-- Exemplo 3: Finalizar aluguel e verificar resultado
DECLARE @multa DECIMAL(10,2);
DECLARE @msg VARCHAR(500);

EXEC SP_FinalizarAluguel
    @p_AluguelID = 11,
    @p_DataDevolucao = GETDATE(),
    @p_FuncionarioID = 1,
    @p_ValorMulta = @multa OUTPUT,
    @p_Mensagem = @msg OUTPUT;


SELECT @multa AS ValorMulta, @msg AS Mensagem;

-- Verifica o aluguel finalizado
SELECT * FROM ALUGUEL WHERE aluguel_id = 11;

-- Verifica multas aplicadas
SELECT * FROM MULTAS WHERE aluguel_id = 11;

-- Verifica equipamentos liberados
SELECT e.* 
FROM EQUIPAMENTO e
INNER JOIN ALUGUEL_ITEM ai ON e.equipamento_id = ai.equipamento_id
WHERE ai.aluguel_id = 11;
GO


-- Listando aluguéis ativos em aberto
SELECT 
    a.aluguel_id,
    c.Nome AS Cliente,
    a.data_inicio,
    a.valor_total,
    COUNT(ai.equipamento_id) AS QtdEquipamentos
FROM ALUGUEL a
INNER JOIN CLIENTES c ON a.cliente_id = c.cliente_id
INNER JOIN ALUGUEL_ITEM ai ON a.aluguel_id = ai.aluguel_id
WHERE a.data_devolucao IS NULL
GROUP BY a.aluguel_id, c.Nome, a.data_inicio, a.valor_total
ORDER BY a.data_inicio;
GO

-- Verificando equipamentos em uso
SELECT 
    e.equipamento_id,
    e.nome,
    e.modelo,
    e.numero_serie,
    e.status,
    a.aluguel_id,
    c.Nome AS Cliente
FROM EQUIPAMENTO e
INNER JOIN ALUGUEL_ITEM ai ON e.equipamento_id = ai.equipamento_id
INNER JOIN ALUGUEL a ON ai.aluguel_id = a.aluguel_id
INNER JOIN CLIENTES c ON a.cliente_id = c.cliente_id
WHERE e.status = 'Em Uso' AND a.data_devolucao IS NULL;
GO

/*
REGRAS DE NEGÓCIO IMPLEMENTADAS:

1. CÁLCULO DE MULTA
   - Multa fixa: R$ 15,00 por dia de atraso
   - Multa proporcional: 10% do valor total do aluguel por dia
   - Fórmula: (15,00 + valor_total * 0,10) * dias_atraso

2. PRAZO PADRÃO DE DEVOLUÇÃO
   - Aluguel até 7 dias: prazo = 7 dias
   - Aluguel de 8-30 dias: prazo = número de dias alugados
   - Aluguel > 30 dias: prazo = 30 dias

3. STATUS DOS EQUIPAMENTOS
   - Antes: 'Em Uso'
   - Depois: 'Disponível'

4. STATUS DE PAGAMENTO DA MULTA
   - Sempre inicia como 'Pendente'
   - Deve ser atualizado manualmente após pagamento

5. ATUALIZAÇÃO DE ESTOQUE
   - Incrementa quant_disponivel
   - Atualiza data_revisao

MELHORIAS FUTURAS:

1. Adicionar parâmetro para devolução parcial de itens
2. Integrar com sistema de notificações
3. Gerar relatório/recibo automático
4. Validar condições dos equipamentos na devolução
5. Registrar fotos/observações da devolução
6. Integrar com sistema de pagamentos
7. Adicionar log de auditoria detalhado
8. Implementar política de descontos para bons clientes

*/