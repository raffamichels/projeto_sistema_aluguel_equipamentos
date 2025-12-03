--6 (AJUSTADA): Duração Média e Máxima Real dos Aluguéis Finalizados
--
-- Mede o tempo que os equipamentos ficam indisponíveis.
-- =========================================================================
SELECT
    -- 1. Duração Média: Calcula a média da diferença em dias entre a devolução e o início.
    CAST(AVG(
        CAST(DATEDIFF(day, A.data_inicio, A.data_devolucao) AS DECIMAL(10, 2))
    ) AS DECIMAL(10, 2)) AS DuracaoMediaRealDias,

    -- 2. Duração Máxima: Calcula o valor máximo da diferença em dias.
    MAX(
        DATEDIFF(day, A.data_inicio, A.data_devolucao)
    ) AS DuracaoMaximaRealDias,

    -- 3. Total de Aluguéis Finalizados (para contexto)
    COUNT(A.aluguel_id) AS TotalAlugueisFinalizados
FROM
    ALUGUEL A
WHERE
    -- Filtra apenas aluguéis que já foram devolvidos.
    A.data_devolucao IS NOT NULL
    -- Garante que as datas sejam válidas (devolução deve ser >= início)
    AND DATEDIFF(day, A.data_inicio, A.data_devolucao) >= 0;