CREATE PROCEDURE SP_FinalizarAluguel  
    @p_AluguelID INT,  
    @p_DataDevolucao DATE = NULL,  
    @p_FuncionarioID INT,  
    @p_ValorMulta DECIMAL(10,2) OUTPUT,  
    @p_Mensagem VARCHAR(500) OUTPUT  
AS  
BEGIN  
    SET NOCOUNT ON;  
      
    -- Variáveis de controle  
    DECLARE @v_DataInicio DATE;  
    DECLARE @v_DataDevolucaoEsperada DATE;  
    DECLARE @v_DiasAluguel INT;  
    DECLARE @v_DiasAtraso INT;  
    DECLARE @v_ValorTotalOriginal DECIMAL(10,2);  
    DECLARE @v_StatusAtual VARCHAR(20);  
    DECLARE @v_ClienteID INT;  
    DECLARE @v_MultaPorDia DECIMAL(10,2) = 15.00;  
    DECLARE @v_PercentualMulta DECIMAL(5,2) = 0.10;  
    DECLARE @v_ValorMultaCalculada DECIMAL(10,2);  
    DECLARE @v_DescricaoMulta VARCHAR(255);  
    DECLARE @v_ItensProcessados INT = 0;  
      
    -- Inicia a transação  
    BEGIN TRANSACTION;  
      
    BEGIN TRY  
          
        -- VALIDAÇÃO 1: Obter dados do aluguel  
        SELECT   
            @v_DataInicio = a.data_inicio,  
            @v_ValorTotalOriginal = a.valor_total,  
            @v_ClienteID = a.cliente_id,  
            @v_StatusAtual = CASE   
                WHEN a.data_devolucao IS NULL THEN 'Ativo'  
                ELSE 'Finalizado'  
            END  
        FROM ALUGUEL a  
        WHERE a.aluguel_id = @p_AluguelID;  
          
        IF @v_ClienteID IS NULL  
        BEGIN  
            SET @p_Mensagem = 'ERRO: Aluguel não encontrado (ID: ' + CAST(@p_AluguelID AS VARCHAR) + ')';  
            SET @p_ValorMulta = 0.00;  
            ROLLBACK TRANSACTION;  
            RETURN 1; -- Código de erro  
        END  
          
        -- VALIDAÇÃO 2: Verificar se já foi finalizado  
        IF @v_StatusAtual = 'Finalizado'  
        BEGIN  
            SET @p_Mensagem = 'ERRO: Aluguel já está finalizado (ID: ' + CAST(@p_AluguelID AS VARCHAR) + ')';  
            SET @p_ValorMulta = 0.00;  
            ROLLBACK TRANSACTION;  
            RETURN 2;  
        END  
          
        -- VALIDAÇÃO 3: Definir data de devolução  
        IF @p_DataDevolucao IS NULL  
            SET @p_DataDevolucao = CAST(GETDATE() AS DATE);  
          
        -- Cálculo simplificado de dias de aluguel  
        SET @v_DiasAluguel = DATEDIFF(DAY, @v_DataInicio, @p_DataDevolucao);  
          
        -- Data de devolução esperada: 7 dias ou a duração, o que for maior (até 30 dias)  
        IF @v_DiasAluguel <= 7  
            SET @v_DataDevolucaoEsperada = DATEADD(DAY, 7, @v_DataInicio);  
        ELSE IF @v_DiasAluguel <= 30  
            SET @v_DataDevolucaoEsperada = DATEADD(DAY, @v_DiasAluguel, @v_DataInicio);  
        ELSE  
            SET @v_DataDevolucaoEsperada = DATEADD(DAY, 30, @v_DataInicio);  
          
        -- Cálculo da multa  
        SET @v_DiasAtraso = DATEDIFF(DAY, @v_DataDevolucaoEsperada, @p_DataDevolucao);  
          
        IF @v_DiasAtraso > 0  
        BEGIN  
            SET @v_ValorMultaCalculada = (@v_MultaPorDia + (@v_ValorTotalOriginal * @v_PercentualMulta)) * @v_DiasAtraso;  
            SET @v_DescricaoMulta = 'Multa por atraso de ' + CAST(@v_DiasAtraso AS VARCHAR) + ' dia(s)';  
        END  
        ELSE  
        BEGIN  
            SET @v_ValorMultaCalculada = 0.00;  
            SET @v_DescricaoMulta = NULL;  
            SET @v_DiasAtraso = 0;  
        END  
          
        SET @p_ValorMulta = @v_ValorMultaCalculada;  
          
        -- 1. Atualizar o aluguel  
        UPDATE ALUGUEL  
        SET   
            data_devolucao = @p_DataDevolucao,  
            valor_total = valor_total + @v_ValorMultaCalculada  
        WHERE aluguel_id = @p_AluguelID;  
          
        -- 2. Registrar multa (se houver)  
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
          
        -- 3. Liberar equipamentos  
        UPDATE E  
        SET E.status = 'Disponível'  
        FROM EQUIPAMENTO E  
        INNER JOIN ALUGUEL_ITEM AI ON E.equipamento_id = AI.equipamento_id  
        WHERE AI.aluguel_id = @p_AluguelID;  
          
        -- 4. Atualizar estoque  
        SELECT   
            equipamento_id,   
            quantidade AS QuantDevolvida  
        INTO #ItensDevolvidos  
        FROM ALUGUEL_ITEM  
        WHERE aluguel_id = @p_AluguelID;  
  
        UPDATE ES  
        SET   
            ES.quant_disponivel = ES.quant_disponivel + ID.QuantDevolvida,  
            ES.data_revisao = CAST(GETDATE() AS DATE)  
        FROM ESTOQUE ES  
        INNER JOIN #ItensDevolvidos ID ON ES.equipamento_id = ID.equipamento_id;  
          
        SET @v_ItensProcessados = @@ROWCOUNT;  
          
        -- Limpar tabela temporária  
        DROP TABLE #ItensDevolvidos;  
          
        -- COMMIT  
        COMMIT TRANSACTION;  
          
        -- Mensagem de sucesso  
        IF @v_DiasAtraso > 0  
        BEGIN  
            SET @p_Mensagem = 'SUCESSO: Aluguel ID ' + CAST(@p_AluguelID AS VARCHAR) +   
                             ' finalizado! Atraso: ' + CAST(@v_DiasAtraso AS VARCHAR) +   
                             ' dia(s). Multa: R$ ' + CAST(@v_ValorMultaCalculada AS VARCHAR(10)) +   
                             '. ' + CAST(@v_ItensProcessados AS VARCHAR) + ' item(ns) liberado(s).';  
        END  
        ELSE  
        BEGIN  
            SET @p_Mensagem = 'SUCESSO: Aluguel ID ' + CAST(@p_AluguelID AS VARCHAR) +   
                             ' finalizado! Devolução no prazo. ' +  
                             CAST(@v_ItensProcessados AS VARCHAR) + ' item(ns) liberado(s).';  
        END  
          
        RETURN 0; -- Sucesso  
          
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0  
            ROLLBACK TRANSACTION;  
          
        IF OBJECT_ID('tempdb..#ItensDevolvidos') IS NOT NULL  
            DROP TABLE #ItensDevolvidos;  
  
        SET @p_Mensagem = 'ERRO: ' + ERROR_MESSAGE() +   
                         ' (Linha: ' + CAST(ERROR_LINE() AS VARCHAR) + ')';  
        SET @p_ValorMulta = 0.00;  
        RETURN -1; -- Erro  
    END CATCH  
END;  