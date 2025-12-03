CREATE TRIGGER TRG_Equipamento_Em_Manutencao
ON MANUTENCAO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualiza o status do equipamento que acaba de ter um registro de manutenção INSERIDO
    UPDATE EQUIPAMENTO
    SET status = 'Em Manutenção'
    WHERE equipamento_id IN (SELECT equipamento_id FROM inserted);
END;
GO