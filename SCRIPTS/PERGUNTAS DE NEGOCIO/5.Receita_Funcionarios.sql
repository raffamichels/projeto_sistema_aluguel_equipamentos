-- 5: Receita Total Gerada por Funcionário (REVISADA E CORRIGIDA)
-- =========================================================================
-- 5: Para cada funcionário, qual o total de receita gerada pelos contratos que ele registrou?
SELECT
    F.funcionario_id,
    F.nome AS NomeFuncionario,
    F.cargo AS CargoFuncionario,
    -- COALESCE garante que funcionários sem aluguéis apareçam com 0.00
    COALESCE(SUM(P.valor_pago), 0.00) AS ReceitaTotalGerada
FROM
    dbo.FUNCIONARIOS F -- Adicionado 'dbo.'
LEFT JOIN
    ALUGUEL A ON F.funcionario_id = A.funcionario_id -- LEFT JOIN para incluir todos os funcionários
LEFT JOIN
    PAGAMENTOS P ON A.aluguel_id = P.aluguel_id     -- Soma todos os pagamentos (aluguéis + multas)
GROUP BY
    F.funcionario_id,
    F.nome,
    F.cargo -- Agrupamento individual por funcionário
ORDER BY
    ReceitaTotalGerada DESC;