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

--Liste os clientes que têm aluguéis ativos há mais de 10 dias E que já possuem multas registradas no passado.

CREATE NONCLUSTERED INDEX IX_ALUGUEL_ATIVO_CLIENTE_DATA
ON ALUGUEL (data_devolucao, data_inicio, cliente_id)
INCLUDE (aluguel_id);

CREATE NONCLUSTERED INDEX IX_MULTAS_ALUGUEL
ON MULTAS (aluguel_id);

SELECT DISTINCT
    C.cliente_id,
    C.Nome,
    A.aluguel_id,
    A.data_inicio
FROM
    CLIENTES C
JOIN
    ALUGUEL A ON C.cliente_id = A.cliente_id
WHERE
    A.data_devolucao IS NULL
    AND DATEDIFF(DAY, A.data_inicio, GETDATE()) > 10
    AND EXISTS (
        SELECT 1
        FROM MULTAS M
        JOIN ALUGUEL A2 ON M.aluguel_id = A2.aluguel_id
        WHERE A2.cliente_id = C.cliente_id
    );