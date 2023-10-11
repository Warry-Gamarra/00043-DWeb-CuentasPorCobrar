using Data.Procedures;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ReportePregradoService : IReporteUnfvService
    {
        public IEnumerable<PagoGeneralDTO> ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPregrado.ReporteGeneral(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPregrado_To_PagoGeneralDTO(p));

            return result;
        }

        public IEnumerable<PagoPorConceptoDTO> ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPregrado.ReportePorConceptos(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPregrado_To_PagoPorConceptoDTO(p));

            return result;
        }

        public IEnumerable<ConceptoPorDependenciaDTO> ReportePorDependenciaYConcepto(
            DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPregrado.ReportePorFacultadYConcepto(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPregrado_To_ConceptoPorDependenciaDTO(p));

            return result;
        }

        public IEnumerable<ConceptoPorDependenciaDTO> ReporteConceptosPorDependencia(
            string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPregrado.ReporteConceptosPorFacultad(codFac, fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPregrado_To_ConceptoPorDependenciaDTO(p));

            return result;
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_ClasificadorDTO> ResumenAnualPagoOblig_X_Clasificadores(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores.Execute(anio, true, entidadFinanID, ctaDepositoID);

            var result = lista.Select(
                x => Mapper.USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores_To_ResumenAnualPagoDeObligaciones_X_ClasificadorDTO(x));

            return result;
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_DependenciaDTO> ResumenAnualPagoOblig_X_Dependencia(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia.Execute(anio, true, entidadFinanID, ctaDepositoID);

            var result = lista.Select(
                x => Mapper.USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia_To_ResumenAnualPagoDeObligaciones_X_DependenciaDTO(x));

            return result;
        }

        public IEnumerable<EstadoObligacionDTO> EstadoObligacionAlumnos(int anio, int? periodo, string codFac, string codEsc, string codRc, 
            bool? esIngresante, bool? estaPagado, bool? obligacionGenerada, DateTime? fechaInicio, DateTime? fechaFin, string codAlu, 
            string nomAlu, string apePaternoAlumno, string apeMaternoAlumno, int? dependenciaID)
        {
            var pr = new USP_S_ListadoEstadoObligaciones_Parameters()
            {
                I_Anio = anio,
                I_Periodo = periodo,
                C_CodFac = codFac,
                C_CodEsc = codEsc,
                C_RcCod = codRc,
                I_TipoEstudio = 1,
                B_Ingresante = esIngresante,
                B_Pagado = estaPagado,
                B_ObligacionGenerada = obligacionGenerada,
                F_FecIni = fechaInicio,
                F_FecFin = fechaFin,
                C_CodAlu = codAlu,
                T_NomAlu = nomAlu,
                T_ApePaternoAlu = apePaternoAlumno,
                T_ApeMaternoAlu = apeMaternoAlumno,
                I_DependenciaID = dependenciaID
            };

            var lista = USP_S_ListadoEstadoObligaciones.Execute(pr);

            var result = lista.Select(x => Mapper.USP_S_ListadoEstadoObligaciones_To_EstadoObligacionDTO(x));

            return result;
        }
    }
}
