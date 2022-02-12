use BD_OCEF_CtasPorCobrar
go


--Anulación de pago por error al registrar
UPDATE p SET p.B_Anulado = 1, p.I_UsuarioMod = 1, p.D_FecMod = GETDATE() FROM dbo.TR_PagoBanco b
INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID
WHERE b.C_CodOperacion = '20220001' AND DATEDIFF(DAY, b.D_FecCre, '20220210') = 0
GO

UPDATE dbo.TR_PagoBanco set B_Anulado = 1, I_UsuarioMod = 1, D_FecMod = GETDATE() 
WHERE C_CodOperacion = '20220001' AND DATEDIFF(DAY, D_FecCre, '20220210') = 0
Go