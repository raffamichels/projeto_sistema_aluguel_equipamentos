-- 4: Liste os clientes que têm aluguéis ativos há mais de 7 dias E que já possuem multas registradas no passado.
SELECT DISTINCT
    C.cliente_id,
    C.nome AS NomeCliente,
    A.aluguel_id,
    A.data_inicio,
    DATEDIFF(day, A.data_inicio, GETDATE()) AS DiasAtivo,
    (
        -- Subconsulta para contar multas no histórico do cliente
        SELECT COUNT(M.multa_id)
        FROM MULTAS M
        INNER JOIN ALUGUEL AA ON M.aluguel_id = AA.aluguel_id
        WHERE AA.cliente_id = C.cliente_id
    ) AS TotalMultasHistorico
FROM
    CLIENTES C
INNER JOIN
    ALUGUEL A ON C.cliente_id = A.cliente_id
WHERE
    -- Condição 1: Aluguel Ativo (não devolvido)
    A.data_devolucao IS NULL
    AND
    -- Condição 2: Ativo há mais de 7 dias
    DATEDIFF(day, A.data_inicio, GETDATE()) > 7
    AND
    -- Condição 3: Cliente tem multas registradas no passado
    C.cliente_id IN (
        SELECT DISTINCT AA.cliente_id
        FROM MULTAS M
        INNER JOIN ALUGUEL AA ON M.aluguel_id = AA.aluguel_id
    )
ORDER BY
    DiasAtivo DESC,
    TotalMultasHistorico DESC;
