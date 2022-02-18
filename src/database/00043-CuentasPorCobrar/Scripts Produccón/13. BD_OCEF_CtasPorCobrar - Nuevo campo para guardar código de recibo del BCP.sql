USE BD_OCEF_CtasPorCobrar
GO


ALTER TABLE TR_PagoBanco ADD C_CodigoInterno VARCHAR(250)
GO

UPDATE TR_PagoBanco SET C_Moneda = 'PEN'
GO


INSERT dbo.TS_CampoTablaPago(T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES('type_dataPagoTasa', 'C_CodigoInterno', 'Código que aparece en el boucher del BCP', 4, 1, 0, 1, GETDATE())
GO


--BANCO COMERCIO: OBLIGACIONES
INSERT TC_ColumnaSeccion(T_ColSecDesc, I_ColumnaInicio, I_ColumnaFin, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_SecArchivoID, I_CampoPagoID)
VALUES('C_CodigoInterno', 1, 0, 1, 0, 1, GETDATE(), 1, 32)
GO

--BANCO COMERCIO: TASAS
INSERT TC_ColumnaSeccion(T_ColSecDesc, I_ColumnaInicio, I_ColumnaFin, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_SecArchivoID, I_CampoPagoID)
VALUES('C_CodigoInterno', 1, 0, 1, 0, 1, GETDATE(), 3, 32)
GO

--BCP: OBLIGACIONES
INSERT TC_ColumnaSeccion(T_ColSecDesc, I_ColumnaInicio, I_ColumnaFin, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_SecArchivoID, I_CampoPagoID)
VALUES('C_CodigoInterno', 226, 250, 1, 0, 1, GETDATE(), 2, 32)
GO

--BCP: TASAS
INSERT TC_ColumnaSeccion(T_ColSecDesc, I_ColumnaInicio, I_ColumnaFin, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_SecArchivoID, I_CampoPagoID)
VALUES('C_CodigoInterno', 243, 300, 1, 0, 1, GETDATE(), 4, 32)
GO
