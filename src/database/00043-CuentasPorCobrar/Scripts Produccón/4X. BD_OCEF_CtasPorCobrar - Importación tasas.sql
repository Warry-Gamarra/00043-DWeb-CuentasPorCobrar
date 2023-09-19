USE BD_OCEF_CtasPorCobrar
GO


--REGISTRO DE TASAS
SET IDENTITY_INSERT dbo.TC_Servicios ON
GO
INSERT dbo.TC_Servicios(I_ServicioID, C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(24, '046', 'UNFV ADMISION 2017', 1, 0, 1, GETDATE())
GO
INSERT dbo.TC_Servicios(I_ServicioID, C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(25, '047', 'UNFV ADMISION 2018', 1, 0, 1, GETDATE())
GO
INSERT dbo.TC_Servicios(I_ServicioID, C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(26, '048', 'UNFV TASAS CARPETA POSTUL 2018', 1, 0, 1, GETDATE())
GO
SET IDENTITY_INSERT dbo.TC_Servicios OFF
GO
DBCC CHECKIDENT ('dbo.TC_Servicios', RESEED, 26);  
GO

INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(7, 6, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(1, 7, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 8, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(5, 10, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(3, 11, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 25, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(1, 21, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 24, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(7, 1, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(7, 2, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 12, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 13, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 15, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 16, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 26, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 19, 1, 0, 1, GETDATE())
GO

UPDATE dbo.TI_CtaDepo_Servicio SET I_CtaDepositoID = 2 WHERE I_CtaDepoServicioID = 5
GO

UPDATE TI_TasaUnfv SET I_TipoObligacion = 10 WHERE I_TipoObligacion IS NULL;
GO

ALTER TABLE TC_Proceso ADD I_CuotaPagoID INT
GO

UPDATE dbo.TC_Proceso SET I_CuotaPagoID = I_ProcesoID
GO