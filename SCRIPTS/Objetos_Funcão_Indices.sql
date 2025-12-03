CREATE FUNCTION fn_CalcularValorRealAluguel (@AluguelID INT)  
RETURNS DECIMAL(10, 2)  
AS  
BEGIN  
    DECLARE @DataInicio DATE;  
    DECLARE @DataDevolucao DATE;  
    DECLARE @DuracaoEmDias INT;  
    DECLARE @CustoDiarioTotal DECIMAL(10, 2);  
    DECLARE @ValorRealFinal DECIMAL(10, 2);
  
    -- 1. Obtém as datas do aluguel
    SELECT   
        @DataInicio = data_inicio,  
        @DataDevolucao = data_devolucao  
    FROM   
        ALUGUEL  
    WHERE   
        aluguel_id = @AluguelID;
      
    -- Se a devolução for nula (aluguel ativo), retorna zero
    IF @DataDevolucao IS NULL  
        RETURN 0.00;
  
    -- 2. Calcula a duração em dias
    SET @DuracaoEmDias = DATEDIFF(day, @DataInicio, @DataDevolucao);
      
    -- Garante que aluguéis de zero dias (início e fim no mesmo dia) contem como 1 dia
    IF @DuracaoEmDias = 0  
        SET @DuracaoEmDias = 1;
      
    -- 3. Calcula o custo diário total dos itens
    SELECT @CustoDiarioTotal = ISNULL(SUM(quantidade * valor_diaria), 0)  
    FROM ALUGUEL_ITEM  
    WHERE aluguel_id = @AluguelID;
      
    -- 4. Calcula o valor final
    SET @ValorRealFinal = @CustoDiarioTotal * @DuracaoEmDias;
  
    RETURN @ValorRealFinal;  
END  
GO