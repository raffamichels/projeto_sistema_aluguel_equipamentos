--1: Qual foi a Receita Líquida Total no último semestre, separando a origem entre Valor de Aluguéis e Multas Pagas?
SELECT
    -- 1. RECEITA DE ALUGUÉIS PAGOS
    -- Soma todos os valores pagos registrados na tabela PAGAMENTOS.
    (
        SELECT
            ISNULL(SUM(P.valor_pago), 0.00)
        FROM
            PAGAMENTOS P
        WHERE
            -- Filtra pagamentos realizados nos últimos 6 meses (último semestre)
            P.dt_pagamento >= DATEADD(month, -6, GETDATE())
            AND P.dt_pagamento <= GETDATE()
    ) AS ReceitaAluguelPaga_Semestre,

    -- 2. RECEITA DE MULTAS PAGAS
    -- Soma o valor das multas, aplicando dois filtros:
    -- a) A multa deve estar com status 'Pago'.
    -- b) A multa deve ter sido registrada nos últimos 6 meses.
    (
        SELECT
            ISNULL(SUM(M.valor_multa), 0.00) -- CORRIGIDO: Usa valor_multa
        FROM
            MULTAS M
        WHERE
            M.status_pagamento = 'Pago'
            -- CORRIGIDO: Usa dt_multa em vez de data_registro
            AND M.dt_multa >= DATEADD(month, -6, GETDATE())
            AND M.dt_multa <= GETDATE()
    ) AS ReceitaMultaPaga_Semestre,

    -- 3. RECEITA LÍQUIDA TOTAL
    -- Soma da Receita de Aluguéis Pagos + Receita de Multas Pagas.
    (
        (
            SELECT ISNULL(SUM(P.valor_pago), 0.00)
            FROM PAGAMENTOS P
            WHERE P.dt_pagamento >= DATEADD(month, -6, GETDATE()) AND P.dt_pagamento <= GETDATE()
        )
        +
        (
            SELECT ISNULL(SUM(M.valor_multa), 0.00) -- CORRIGIDO: Usa valor_multa
            FROM MULTAS M
            WHERE M.status_pagamento = 'Pago'
            -- CORRIGIDO: Usa dt_multa em vez de data_registro
            AND M.dt_multa >= DATEADD(month, -6, GETDATE()) AND M.dt_multa <= GETDATE()
        )
    ) AS ReceitaLiquidaTotal_Semestre;