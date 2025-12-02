--Qual a diferença média (em dias) entre a data de devolução real e a data de previsão de devolução?
--Regra adotada: Data prevista = data_inicio + 5 dias.

CREATE INDEX IDX_ALUGUEL_DEVOLUCAO
ON ALUGUEL (data_devolucao, data_inicio);

SELECT 
    AVG(
        DATEDIFF(
            DAY,
            DATEADD(DAY, 5, data_inicio),
            data_devolucao
        )
    ) AS media_dias
FROM ALUGUEL
WHERE data_devolucao IS NOT NULL;
