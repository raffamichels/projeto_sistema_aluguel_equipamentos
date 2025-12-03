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
GO

--Justificativa:
--Essa função centraliza o cálculo do valor real de um aluguel finalizado.
--Em vez de confiar em um valor pré-definido, ela recalcula o preço exato multiplicando a duração real do aluguel (em dias) pelo custo diário dos itens.
--Isso ajuda a evitar erros de faturamento, garantindo que o valor cobrado seja sempre preciso, mesmo que a data de devolução seja diferente da prevista.
--Além disso, serve como uma ferramenta de auditoria para verificar a consistência dos dados financeiros e simplifica a criação de relatórios precisos.
