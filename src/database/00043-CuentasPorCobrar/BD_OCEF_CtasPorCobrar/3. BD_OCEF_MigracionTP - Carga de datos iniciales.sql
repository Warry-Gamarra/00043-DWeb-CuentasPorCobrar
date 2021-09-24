USE BD_OCEF_MigracionTP
GO

INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (1, 'El nombre de alumno tiene caracteres extra�os', 'CARACTERES', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (2, 'La combinaci�n c�digo de carrera + c�digo de alumno se encuentran repetidos', 'REPETIDO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (3, 'La cuota de pago se encuentra repetida con estado ACTIVO', 'REPETIDO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (4, 'La cuota de pago se encuentra repetida con estado ELIMINADO', 'REPETIDO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (5, 'La cuota de pago presenta m�s de un a�o asociado en las tablas cp_pri o ec_det.', '1+ A�OS', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (6, 'La cuota de pago no presenta a�o asociado en las tablas cp_pri o ec_det', '0 A�OS', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (7, 'La cuota de pago presenta m�s de un periodo asociado en la tabla cp_pri', '1+ PERIODOS', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (8, 'La cuota de pago no presenta un periodo asociado en la tabla cp_pri.', '0 PERIODOS', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (9, 'La cuota de pago presenta m�s de una categor�a seg�n codBanco', '1+ CATEGORIAS', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (10, 'La cuota de pago no presenta una categoria asociada seg�n codBanco.', '0 CATEGORIAS', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (11, 'La cuota de pago ha sido ingresada o modificada desde una fuente externa.', 'EXTERNO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (12, 'El concepto de pago se encuentra repetido con estado ACTIVO', 'REPETIDO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (13, 'El concepto de pago se encuentra repetido con estado ELIMINADO', 'REPETIDO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (14, 'Concepto de pago de obligacion sin a�o asignado', '0 A�OS', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (15, 'A�o del concepto de pago de obligacion no coincide con el a�o de la cuota de pagos.', 'NO COINCIDE A�O', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (16, 'Concepto de pago de obligacion sin cuota de pago.', '0 PERIODO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (17, 'Concepto de pago de obligacion sin cuota de pago.', 'NO COINCIDE PERIODO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (18, 'Concepto de pago de obligacion sin cuota de pago.', 'SIN CUOTA', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (19, 'La cuota de pago asociada no fue migrada.', 'SIN CUOTA MIGRADA', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (20, 'El concepto de pago ha sido ingresado o modificado desde una fuente externa.', 'EXTERNO', NULL)
INSERT INTO TC_CatalogoObservacion (I_ObservID, T_ObservDesc, T_ObservCod, I_Severidad) VALUES (21, 'No se encontr� c�digo de carrera asociado en la base de datos de repositorio.', 'SIN CARRERA', NULL)


INSERT INTO TC_CatalogoTabla (I_TablaID, T_TablaNom) VALUES (1, 'TR_MG_Alumnos')
INSERT INTO TC_CatalogoTabla (I_TablaID, T_TablaNom) VALUES (2, 'TR_MG_CpDes')
INSERT INTO TC_CatalogoTabla (I_TablaID, T_TablaNom) VALUES (3, 'TR_MG_CpPri')
INSERT INTO TC_CatalogoTabla (I_TablaID, T_TablaNom) VALUES (4, 'TR_MG_EcDet')
INSERT INTO TC_CatalogoTabla (I_TablaID, T_TablaNom) VALUES (5, 'TR_MG_EcObl')
INSERT INTO TC_CatalogoTabla (I_TablaID, T_TablaNom) VALUES (6, 'TR_MG_EcPri')


