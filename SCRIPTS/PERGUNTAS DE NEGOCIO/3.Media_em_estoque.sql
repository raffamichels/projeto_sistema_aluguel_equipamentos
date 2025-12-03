-- 3: Tempo Médio de Permanência em Estoque
-- =========================================================================
-- E.1: Qual o tempo médio de permanência em estoque (dias desde a última data_revisao)
-- para equipamentos que foram alugados mais de 1 vezes? (AJUSTADO PARA TESTE)
SELECT
    E.nome AS NomeEquipamento,
    C.nome_categoria AS Categoria,
    ES.data_revisao AS DataUltimaRevisao,
    COUNT(AI.equipamento_id) AS TotalAlugueis,
    -- Calcula a diferença em dias entre a data atual e a data da última revisão
    DATEDIFF(day, ES.data_revisao, GETDATE()) AS DiasDesdeUltimaRevisao,
    -- (Opcional) Calcula a média geral do tempo em estoque (dias) para o conjunto filtrado
    AVG(DATEDIFF(day, ES.data_revisao, GETDATE())) OVER () AS TempoMedioGeral_Dias
FROM
    EQUIPAMENTO E
INNER JOIN
    CATEGORIA C ON E.categoria_id = C.categoria_id
INNER JOIN
    ALUGUEL_ITEM AI ON E.equipamento_id = AI.equipamento_id
INNER JOIN
    ESTOQUE ES ON E.equipamento_id = ES.equipamento_id
GROUP BY
    E.equipamento_id,
    E.nome,
    C.nome_categoria,
    ES.data_revisao
HAVING
    -- Filtra apenas equipamentos que foram alugados mais de 3 vezes
    COUNT(AI.equipamento_id) > 1 -- REDUZIDO O LIMITE PARA TESTE
ORDER BY
    TotalAlugueis DESC,
    DiasDesdeUltimaRevisao DESC;