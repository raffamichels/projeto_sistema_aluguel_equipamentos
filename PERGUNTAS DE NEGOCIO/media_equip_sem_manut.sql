-- 1. PERGUNTA DE NEGÓCIO:
-- "Qual o tempo médio de permanência em estoque (dias desde a última revisão) 
-- para equipamentos que são muito populares (alugados 2 ou mais vezes)?"
--
-- 2. OBJETIVO:
-- Identificar se os equipamentos mais utilizados que estão com a manutenção/revisão em dia 
-- ou se estão há muito tempo sem vistoria, o que poderia gerar risco de quebra.

SELECT 
    e.nome AS Equipamento,
    
    COUNT(ai.aluguel_id) AS Qtd_Alugueis,
    
    est.data_revisao AS Data_Ultima_Revisao,
    
    AVG(DATEDIFF(DAY, est.data_revisao, GETDATE())) AS Dias_Sem_Revisao

FROM ESTOQUE est

    INNER JOIN EQUIPAMENTO e ON est.equipamento_id = e.equipamento_id
    INNER JOIN ALUGUEL_ITEM ai ON e.equipamento_id = ai.equipamento_id

GROUP BY 
    e.nome, 
    est.data_revisao


HAVING 
    COUNT(ai.aluguel_id) >= 2

ORDER BY 
    Qtd_Alugueis DESC;