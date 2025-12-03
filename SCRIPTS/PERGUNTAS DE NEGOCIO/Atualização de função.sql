-- =========================================================================
-- FUNÇÃO: fn_CalcularValorRealAluguel
-- OBJETIVO: Garante que a função exista e esteja atualizada.
-- =========================================================================

-- Verifica se a função já existe
IF OBJECT_ID('fn_CalcularValorRealAluguel') IS NOT NULL
BEGIN
    -- Se existir, usa ALTER para atualizar o código (se necessário)
    EXEC('
    ALTER FUNCTION fn_CalcularValorRealAluguel (@AluguelID INT)  
    RETURNS DECIMAL(10, 2)  
    AS  
    BEGIN  
        DECLARE @DataInicio DATE;  
        DECLARE @DataDevolucao DATE;  
        DECLARE @DuracaoEmDias INT;  
        DECLARE @CustoDiarioTotal DECIMAL(10, 2);  
        DECLARE @ValorRealFinal DECIMAL(10, 2);
      
        SELECT   
            @DataInicio = data_inicio,  
            @DataDevolucao = data_devolucao  
        FROM   
            ALUGUEL  
        WHERE   
            aluguel_id = @AluguelID;
          
        IF @DataDevolucao IS NULL  
            RETURN 0.00;
      
        SET @DuracaoEmDias = DATEDIFF(day, @DataInicio, @DataDevolucao);
          
        IF @DuracaoEmDias = 0  
            SET @DuracaoEmDias = 1;
          
        SELECT @CustoDiarioTotal = ISNULL(SUM(quantidade * valor_diaria), 0)  
        FROM ALUGUEL_ITEM  
        WHERE aluguel_id = @AluguelID;
          
        SET @ValorRealFinal = @CustoDiarioTotal * @DuracaoEmDias;
      
        RETURN @ValorRealFinal;  
    END
    ');
END
ELSE
BEGIN
    -- Se não existir, usa CREATE
    EXEC('
    CREATE FUNCTION fn_CalcularValorRealAluguel (@AluguelID INT)  
    RETURNS DECIMAL(10, 2)  
    AS  
    BEGIN  
        DECLARE @DataInicio DATE;  
        DECLARE @DataDevolucao DATE;  
        DECLARE @DuracaoEmDias INT;  
        DECLARE @CustoDiarioTotal DECIMAL(10, 2);  
        DECLARE @ValorRealFinal DECIMAL(10, 2);
      
        SELECT   
            @DataInicio = data_inicio,  
            @DataDevolucao = data_devolucao  
        FROM   
            ALUGUEL  
        WHERE   
            aluguel_id = @AluguelID;
          
        IF @DataDevolucao IS NULL  
            RETURN 0.00;
      
        SET @DuracaoEmDias = DATEDIFF(day, @DataInicio, @DataDevolucao);
          
        IF @DuracaoEmDias = 0  
            SET @DuracaoEmDias = 1;
          
        SELECT @CustoDiarioTotal = ISNULL(SUM(quantidade * valor_diaria), 0)  
        FROM ALUGUEL_ITEM  
        WHERE aluguel_id = @AluguelID;
          
        SET @ValorRealFinal = @CustoDiarioTotal * @DuracaoEmDias;
      
        RETURN @ValorRealFinal;  
    END
    ');
END
GO