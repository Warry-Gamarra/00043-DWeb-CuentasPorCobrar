use BD_OCEF_CtasPorCobrar
go

/*
Anulación de pagos duplicados, por error en carga.
*/

UPDATE dbo.TR_PagoBanco SET B_Anulado = 1
WHERE I_CondicionPagoID = 137 AND DATEDIFF(DAY, D_FecCre, '20211228') = 0
GO

/*
Anulación de pagos duplicados (extornos).
*/
UPDATE dbo.TR_PagoBanco SET B_Anulado = 1
WHERE I_CondicionPagoID = 132 AND C_CodDepositante IN ('2021003088', '2019321253') AND DATEDIFF(DAY, D_FecCre, '20211223') = 0

UPDATE dbo.TR_PagoBanco SET B_Anulado = 1
WHERE I_CondicionPagoID = 132 AND C_CodDepositante = '2020007482' AND DATEDIFF(DAY, D_FecCre, '20211228') = 0
GO