using Data.Procedures;
using Data.Tables;
using Data.Types;
using Data.Views;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public static class Mapper
    {
        public static MatriculaObsEntity MatriculaEntity_To_MatriculaObsEntity(MatriculaEntity matricula, bool B_Success, string T_Message)
        {
            var dataMatriculaObs = new MatriculaObsEntity()
            {
                C_CodRC = matricula.C_CodRC,
                C_CodAlu = matricula.C_CodAlu,
                I_Anio = matricula.I_Anio,
                C_Periodo = matricula.C_Periodo,
                C_EstMat = matricula.C_EstMat,
                C_Ciclo = matricula.C_Ciclo,
                B_Ingresante = matricula.B_Ingresante,
                I_CredDesaprob = matricula.I_CredDesaprob,
                B_Success = B_Success,
                T_Message = T_Message
            };

            return dataMatriculaObs;
        }

        public static DataTable MatriculaEntity_To_DataTable(List<MatriculaEntity> dataMatriculas)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("C_CodRC");
            dataTable.Columns.Add("C_CodAlu");
            dataTable.Columns.Add("I_Anio");
            dataTable.Columns.Add("C_Periodo");
            dataTable.Columns.Add("C_EstMat");
            dataTable.Columns.Add("C_Ciclo");
            dataTable.Columns.Add("B_Ingresante");
            dataTable.Columns.Add("I_CredDesaprob");
            dataTable.Columns.Add("B_ActObl");

            dataMatriculas.ForEach(x => dataTable.Rows.Add(
                x.C_CodRC,
                x.C_CodAlu,
                x.I_Anio,
                x.C_Periodo,
                x.C_EstMat,
                x.C_Ciclo,
                x.B_Ingresante,
                x.I_CredDesaprob,
                x.B_ActObl
            ));

            return dataTable;
        }

        public static MatriculaObsEntity DataMatriculaResult_To_MatriculaObsEntity(DataMatriculaResult result)
        {
            var matriculaObs = new MatriculaObsEntity()
            {
                C_CodRC = result.C_CodRC,
                C_CodAlu = result.C_CodAlu,
                I_Anio = result.I_Anio,
                C_Periodo = result.C_Periodo,
                C_EstMat = result.C_EstMat,
                C_Ciclo = result.C_Ciclo,
                B_Ingresante = result.B_Ingresante,
                I_CredDesaprob = result.I_CredDesaprob,
                B_Success = result.B_Success,
                T_Message = result.T_Message
            };

            return matriculaObs;
        }

        public static MatriculaDTO MatriculaDTO_To_VW_MatriculaAlumno(VW_MatriculaAlumno matriculaAlumno)
        {
            var matriculaDTO = new MatriculaDTO()
            {
                I_MatAluID = matriculaAlumno.I_MatAluID,
                C_CodAlu = matriculaAlumno.C_CodAlu,
                C_RcCod = matriculaAlumno.C_RcCod,
                T_Nombre = matriculaAlumno.T_Nombre,
                T_ApePaterno = matriculaAlumno.T_ApePaterno,
                T_ApeMaterno = matriculaAlumno.T_ApeMaterno,
                N_Grado = matriculaAlumno.N_Grado,
                I_Anio = matriculaAlumno.I_Anio,
                I_Periodo = matriculaAlumno.I_Periodo,
                C_CodFac = matriculaAlumno.C_CodFac,
                C_EstMat = matriculaAlumno.C_EstMat,
                C_Ciclo = matriculaAlumno.C_Ciclo,
                B_Ingresante = matriculaAlumno.B_Ingresante,
                I_CredDesaprob = matriculaAlumno.I_CredDesaprob,
                B_Habilitado = matriculaAlumno.B_Habilitado
            };

            return matriculaDTO;
        }

        public static ObligacionDetalleDTO VW_DetalleObligaciones_To_ObligacionDetalleDTO(VW_DetalleObligaciones detalleObligaciones)
        {
            var obligacionDetalleDTO = new ObligacionDetalleDTO()
            {
                I_ObligacionAluID = detalleObligaciones.I_ObligacionAluID,
                I_ProcesoID = detalleObligaciones.I_ProcesoID,
                N_CodBanco = detalleObligaciones.N_CodBanco ?? "",
                C_CodAlu = detalleObligaciones.C_CodAlu,
                C_CodRc = detalleObligaciones.C_CodRc,
                C_CodFac = detalleObligaciones.C_CodFac,
                T_Nombre = detalleObligaciones.T_Nombre,
                T_ApePaterno = detalleObligaciones.T_ApePaterno,
                T_ApeMaterno = detalleObligaciones.T_ApeMaterno ?? "",
                I_Anio = detalleObligaciones.I_Anio,
                I_Periodo = detalleObligaciones.I_Periodo,
                C_Periodo = detalleObligaciones.C_Periodo,
                T_Periodo = detalleObligaciones.T_Periodo,
                T_ProcesoDesc = detalleObligaciones.T_ProcesoDesc,
                T_ConceptoDesc = detalleObligaciones.T_ConceptoDesc,
                T_CatPagoDesc = detalleObligaciones.T_CatPagoDesc,
                I_Monto = detalleObligaciones.I_Monto,
                B_Pagado = detalleObligaciones.B_Pagado,
                D_FecVencto = detalleObligaciones.D_FecVencto,
                I_Prioridad = detalleObligaciones.I_Prioridad,
                C_CodOperacion = detalleObligaciones.C_CodOperacion ?? "",
                D_FecPago = detalleObligaciones.D_FecPago,
                T_LugarPago = detalleObligaciones.T_LugarPago ?? "",
                C_Moneda = detalleObligaciones.C_Moneda,
                I_TipoObligacion = detalleObligaciones.I_TipoObligacion,
                I_Nivel = detalleObligaciones.I_Nivel,
                C_Nivel = detalleObligaciones.C_Nivel,
                T_Nivel = detalleObligaciones.T_Nivel,
                I_TipoAlumno = detalleObligaciones.I_TipoAlumno,
                C_TipoAlumno = detalleObligaciones.C_TipoAlumno,
                T_TipoAlumno = detalleObligaciones.T_TipoAlumno
            };

            return obligacionDetalleDTO;
        }

        public static CuotaPagoDTO VW_CuotaPago_To_CuotaPagoDTO(VW_CuotasPago cuotaPago)
        {
            var cuotaPagoDTO = new CuotaPagoDTO()
            {
                I_NroOrden = cuotaPago.I_NroOrden,
                I_ObligacionAluID = cuotaPago.I_ObligacionAluID,
                I_ProcesoID = cuotaPago.I_ProcesoID,
                N_CodBanco = cuotaPago.N_CodBanco ?? "",
                C_CodAlu = cuotaPago.C_CodAlu,
                C_CodRc = cuotaPago.C_CodRc,
                C_CodFac = cuotaPago.C_CodFac,
                T_Nombre = cuotaPago.T_Nombre,
                T_ApePaterno = cuotaPago.T_ApePaterno,
                T_ApeMaterno = cuotaPago.T_ApeMaterno ?? "",
                I_Anio = cuotaPago.I_Anio,
                I_Periodo = cuotaPago.I_Periodo,
                C_Periodo = cuotaPago.C_Periodo,
                T_Periodo = cuotaPago.T_Periodo,
                T_ProcesoDesc = cuotaPago.T_ProcesoDesc,
                D_FecVencto = cuotaPago.D_FecVencto,
                I_Prioridad = cuotaPago.I_Prioridad,
                C_Moneda = cuotaPago.C_Moneda,
                C_Nivel = cuotaPago.C_Nivel,
                C_TipoAlumno = cuotaPago.C_TipoAlumno,
                I_MontoOblig = cuotaPago.I_MontoOblig,
                B_Pagado = cuotaPago.B_Pagado,
                C_CodOperacion = cuotaPago.C_CodOperacion,
                D_FecPago = cuotaPago.D_FecPago,
                T_LugarPago = cuotaPago.T_LugarPago
            };

            return cuotaPagoDTO;
        }

        public static CatalogoOpcionEntity TC_CatalogoOpcion_To_CatalogoOpcionEntity(TC_CatalogoOpcion catalogoOpcion)
        {
            var catalogoOpcionEntity = new CatalogoOpcionEntity()
            {
                I_OpcionID = catalogoOpcion.I_OpcionID,
                T_OpcionCod = catalogoOpcion.T_OpcionCod,
                T_OpcionDesc = catalogoOpcion.T_OpcionDesc,
                B_Habilitado = catalogoOpcion.B_Habilitado
            };

            return catalogoOpcionEntity;
        }

        public static Proceso USP_S_Procesos_To_Proceso(USP_S_Procesos uspProceso)
        {
            var proceso = new Proceso()
            {
                I_ProcesoID = uspProceso.I_ProcesoID,
                I_CatPagoID = uspProceso.I_CatPagoID,
                T_CatPagoDesc = uspProceso.T_CatPagoDesc,
                C_PeriodoCod = uspProceso.C_PeriodoCod,
                T_PeriodoDesc = uspProceso.T_PeriodoDesc,
                T_ProcesoDesc = uspProceso.T_ProcesoDesc,
                I_Periodo = uspProceso.I_Periodo,
                I_Anio = uspProceso.I_Anio,
                D_FecVencto = uspProceso.D_FecVencto,
                I_Prioridad = uspProceso.I_Prioridad,
                N_CodBanco = uspProceso.N_CodBanco,
                B_Obligacion = uspProceso.B_Obligacion,
                I_Nivel = uspProceso.I_Nivel,
                C_Nivel = uspProceso.C_Nivel
            };

            return proceso;
        }

        public static DataTable PagoObligacionEntity_To_DataTable(List<PagoObligacionEntity> dataPagoObligaciones)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("C_CodOperacion");
            dataTable.Columns.Add("T_NomDepositante");
            dataTable.Columns.Add("C_Referencia");
            dataTable.Columns.Add("D_FecPago");
            dataTable.Columns.Add("I_Cantidad");
            dataTable.Columns.Add("C_Moneda");
            dataTable.Columns.Add("I_MontoPago");
            dataTable.Columns.Add("T_LugarPago");
            dataTable.Columns.Add("C_CodAlu");
            dataTable.Columns.Add("C_CodRc");
            dataTable.Columns.Add("I_ProcesoID");
            dataTable.Columns.Add("D_FecVencto");

            dataPagoObligaciones.ForEach(x => dataTable.Rows.Add(
                x.C_CodOperacion,
                x.T_NomDepositante,
                x.C_Referencia,
                x.D_FecPago,
                x.I_Cantidad,
                x.C_Moneda,
                x.I_MontoPago,
                x.T_LugarPago,
                x.C_CodAlu,
                x.C_CodRc,
                x.I_ProcesoID,
                x.D_FecVencto
            ));

            return dataTable;
        }

        public static CtaDepoProceso VW_CtaDepositoProceso_To_CtaDepoProceso(VW_CtaDepositoProceso vwCtaDepositoProceso)
        {
            var ctaDepoProceso = new CtaDepoProceso()
            {
                I_CtaDepoProID = vwCtaDepositoProceso.I_CtaDepoProID,
                I_EntidadFinanID = vwCtaDepositoProceso.I_EntidadFinanID,
                T_EntidadDesc = vwCtaDepositoProceso.T_EntidadDesc,
                I_CtaDepositoID = vwCtaDepositoProceso.I_CtaDepositoID,
                C_NumeroCuenta = vwCtaDepositoProceso.C_NumeroCuenta,
                T_DescCuenta = vwCtaDepositoProceso.T_DescCuenta,
                I_ProcesoID = vwCtaDepositoProceso.I_ProcesoID,
                T_ProcesoDesc = vwCtaDepositoProceso.T_ProcesoDesc,
                I_Prioridad = vwCtaDepositoProceso.I_Prioridad,
                I_Anio = vwCtaDepositoProceso.I_Anio,
                I_Periodo = vwCtaDepositoProceso.I_Periodo,
                C_Periodo = vwCtaDepositoProceso.C_Periodo,
                T_PeriodoDesc = vwCtaDepositoProceso.T_PeriodoDesc,
                I_Nivel = vwCtaDepositoProceso.I_Nivel,
                C_Nivel = vwCtaDepositoProceso.C_Nivel,
                B_Habilitado = vwCtaDepositoProceso.B_Habilitado
            };

            return ctaDepoProceso;
        }
    }
}
