CREATE NONCLUSTERED INDEX IX_EQUIP_CATEGORIA
ON EQUIPAMENTO (categoria_id)
INCLUDE (equipamento_id);

CREATE NONCLUSTERED INDEX IX_ALUGUELITEM_EQUIP
ON ALUGUEL_ITEM (equipamento_id);

CREATE NONCLUSTERED INDEX IX_MANUTENCAO_EQUIP
ON MANUTENCAO (equipamento_id);

WITH ReceitaPorCategoria AS (
    SELECT
        E.categoria_id,
        SUM(AI.valor_diaria * AI.quantidade) AS ReceitaTotal
    FROM
        ALUGUEL_ITEM AI
    JOIN
        EQUIPAMENTO E ON AI.equipamento_id = E.equipamento_id
    GROUP BY
        E.categoria_id
),
CustoPorCategoria AS (
    SELECT
        E.categoria_id,
        SUM(M.custo) AS CustoTotal
    FROM
        MANUTENCAO M
    JOIN
        EQUIPAMENTO E ON M.equipamento_id = E.equipamento_id
    GROUP BY
        E.categoria_id
)
SELECT
    C.nome_categoria AS Categoria,
    ISNULL(RC.ReceitaTotal, 0.00) AS Receita_Total_Aluguel,
    ISNULL(CC.CustoTotal, 0.00) AS Custo_Total_Manutencao,
    CASE
        WHEN ISNULL(CC.CustoTotal, 0.00) = 0 THEN NULL 
        ELSE ((ISNULL(RC.ReceitaTotal, 0.00) - ISNULL(CC.CustoTotal, 0.00)) / ISNULL(CC.CustoTotal, 0.00)) * 100
    END AS ROI_Percentual
FROM
    CATEGORIA C
LEFT JOIN
    ReceitaPorCategoria RC ON C.categoria_id = RC.categoria_id
LEFT JOIN
    CustoPorCategoria CC ON C.categoria_id = CC.categoria_id
ORDER BY
    ROI_Percentual DESC;