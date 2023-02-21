USE BD_OCEF_CtasPorCobrar
GO

--Actualización del código de tasa 00000 a 83444
UPDATE p SET I_TasaUnfvID = 34 FROM dbo.TR_PagoBanco b
INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID
WHERE b.B_Anulado = 0 AND p.B_Anulado = 0 AND b.I_EntidadFinanID = 2 AND b.T_InformacionAdicional LIKE '083444%' AND p.I_TasaUnfvID = 33
GO
