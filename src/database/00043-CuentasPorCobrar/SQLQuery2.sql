--select distinct N_CTA_CTE, CODIGO_BNC from cp_des WHERE ELIMINADO = 1 
--select * from cp_des WHERE N_CTA_CTE = '110-01-0414438' 
--select DISTINCT N_CTA_CTE from cp_des where CODIGO_BNC is NOT null
--select * from cp_des where CODIGO_BNC is null

select * from cp_des where CODIGO_BNC = (
--'0635'
--'0636'
--'0637'  -- OTROS-PAGOS-REG hasta 2012
--'0638'
--'0639' --2019-MAT-INGRESANTE -- OTROS-PAGOS-REG desde 2013
--'0658' --2013 MAT.REGUL.EUDED - UNICA FILA CP_DES Y UNICA FILA EN CP_PRI
--'0670'
--'0671'
--'0672'  **** OBS MATRICULA EUPG MAESTRÍA SEMIPRESENCIAL INGRESANTE Y REGULAR MISMO COD_BNC
--'0673'  **** OBS 
--'0674'
--'0675'
--'0676'  **** OBS PENSION EUPG DOCTORADO SEMIPRESENCIAL SOLO APARECE UNA VEZ PERO EN CP_PRI APARECEN ING Y REG, ING ELIMINADO
--'0677'  **** OBS PENSION EUPG MAESTRÍA SEMIPRESENCIAL INGRESANTE Y REGULAR MISMO COD_BNC
--'0678'
--'0679'
'0680'
--'0681'
--'0682'
--'0683'
--'0685'  **** OBS - matricula de ingresantes y regular EUDED mismo codigo de banco
--'0687'  **** OBS - pensión de ingresantes y regular EUDED mismo codigo de banco en cp_des
--'0688'  **** OBS - en 2007 pensión de ingresantes EUDED codigo de banco en cp_des
--'0689'
--'0690'
--'0691'
--'0692'
--'0695'
--'0696'
--'0697'
--'0698'
)
 AND ELIMINADO = 0

 SELECT * FROM cp_des
 WHERE ELIMINADO = 0 AND CODIGO_BNC IS NOT NULL -- IN (
		--'0635','0636','0638','0670','0671','0674',
		--'0675','0676','0677','0678','0679','0680',
		--'0681','0682','0683','0687','0688','0689',
		--'0690','0691','0692','0695','0696','0697',
		--'0698')

SELECT * FROM cp_des WHERE  cuota_pago = 143 --CODIGO_BNC = '0677'
SELECT * FROM cp_pri WHERE cuota_pago = 155

SELECT * FROM cp_pri WHERE cuota_pago IN (
SELECT CUOTA_PAGO FROM cp_des WHERE CODIGO_BNC = '0677')

---236 + 214 = 450

SELECT DISTINCT cuota_pago, ano, p 
FROM cp_pri
WHERE eliminado = 0



select distinct cp_pri.descripcio, monto from cp_pri
inner join cp_des on cp_pri.cuota_pago = cp_des.CUOTA_PAGO 
where cp_des.ELIMINADO = 0 and cp_pri.eliminado = 0
and cp_des.CODIGO_BNC is not null