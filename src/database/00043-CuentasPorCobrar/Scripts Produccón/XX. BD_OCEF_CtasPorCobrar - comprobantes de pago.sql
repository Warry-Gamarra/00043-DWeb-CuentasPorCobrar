/*
1. CADA PAGO DE ALUMNO EST� RELACIONADO A UN TIPO DE COMPROBANTE.
	-BOLETA, FACTURA, NOTA DE CR�DITO, NOTA DE D�BITO.
	-Agravado

2. La b�squeda de los pagos se har� bajo los criterios de:
	-varios criterios
	-Pagos con fecha de antiguedada  7 d�as o seg�n criterio

3. Al tener el(los) pago(s) se le asignar� el "tipo de comprobante", "serie", "numeraci�n" e internamente un "estado".
	-Criterio de serie: un n�mero fijo.
	-Criterio de numeraci�n: por serie del 1 al n.
	-Estado: procesado, pendiente y con errores.

4. Una vez se tenga la relaci�n de pagos se generar� el TXT seg�n formato de digiflow y se almacenar� en la ruta.
*/

USE BD_OCEF_CtasPorCobrar
GO

CREATE TABLE dbo.TC_TipoComprobante
(
	I_TipoComprobanteID INT IDENTITY(1,1),
	C_TipoComprobanteCod VARCHAR(50) NOT NULL,
	T_TipoComprobanteDesc VARCHAR(250) NOT NULL,
	B_Habilitado BIT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_TipoComprobante PRIMARY KEY (I_TipoComprobanteID)
)
GO

CREATE TABLE dbo.TC_EstadoComprobante
(
	I_EstadoComprobanteID INT IDENTITY(1,1),
	C_EstadoComprobanteCod VARCHAR(50) NOT NULL,
	T_EstadoComprobanteDesc VARCHAR(250) NOT NULL,
	B_Habilitado BIT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_EstadoComprobante PRIMARY KEY (I_EstadoComprobanteID)
)
GO

CREATE TABLE dbo.TR_ComprobantePago(
	I_ComprobantePagoID INT IDENTITY(1,1),
	I_TipoComprobanteID INT NOT NULL,
	I_NumeroSerie INT NOT NULL,
	I_NumeroComprobante INT NOT NULL,	
	B_EsGravado BIT NOT NULL,--EN EL EXCEL GRE->CATALOGOSUNAT->CELDA 109 HAY UNA TABLA TIPO DE AFECTO, CONSULTAR SI ESTE VALOR SE OBTIENE DE AH�, o lo dejo como booleano.
	D_FechaEmision DATETIME NOT NULL,
	I_EstadoComprobanteID INT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_ComprobantePago PRIMARY KEY (I_ComprobantePagoID),
	CONSTRAINT FK_TipoComprobante_ComprobantePago FOREIGN KEY (I_TipoComprobanteID) REFERENCES TC_TipoComprobante(I_TipoComprobanteID),
	CONSTRAINT FK_Estado_ComprobantePago FOREIGN KEY (I_EstadoComprobanteID) REFERENCES TC_EstadoComprobante(I_EstadoComprobanteID),
	CONSTRAINT UQ_ComprobantePago UNIQUE (I_NumeroSerie, I_NumeroComprobante)
)
GO

ALTER TABLE dbo.TR_PagoBanco ADD I_ComprobantePagoID INT
GO

ALTER TABLE dbo.TR_PagoBanco ADD CONSTRAINT FK_ComprobantePago_PagoBanco FOREIGN KEY (I_ComprobantePagoID) REFERENCES TR_ComprobantePago(I_ComprobantePagoID)
GO

INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('01', 'Factura', 0, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('03', 'Boleta de venta', 1, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('07', 'Nota de cr�dito', 0, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('08', 'Nota de d�bito', 0, 1, GETDATE())
GO

INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('PEN', 'Pendiente', 1, 1, GETDATE())
INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('PRO', 'Procesado', 1, 1, GETDATE())
INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('ERR', 'Error', 1, 1, GETDATE())
GO

CREATE TYPE dbo.type_Ids AS TABLE(ID INT)
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarComprobantePago')
	DROP PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
@PagoBancoIDs [dbo].[type_Ids] READONLY,
@I_TipoComprobanteID INT,
@I_NumeroSerie INT,
@I_NumeroComprobante INT,
@B_EsGravado BIT,
@D_FechaEmision DATETIME,
@I_EstadoComprobanteID INT,
@UserID INT,
@B_Result BIT OUTPUT,  
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;
	
	DECLARE @I_ComprobantePagoID INT;

	BEGIN TRAN
	BEGIN TRY
		
		INSERT dbo.TR_ComprobantePago(I_TipoComprobanteID, I_NumeroSerie, I_NumeroComprobante, B_EsGravado, D_FechaEmision, I_EstadoComprobanteID, I_UsuarioCre, D_FecCre)
		VALUES(@I_TipoComprobanteID, @I_NumeroSerie, @I_NumeroComprobante, @B_EsGravado, @D_FechaEmision, @I_EstadoComprobanteID, @UserID, GETDATE());

		SET @I_ComprobantePagoID = SCOPE_IDENTITY();

		UPDATE dbo.TR_PagoBanco SET I_ComprobantePagoID = @I_ComprobantePagoID WHERE I_PagoBancoID IN (SELECT ID FROM @PagoBancoIDs)
		
		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Grabaci�n correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO

