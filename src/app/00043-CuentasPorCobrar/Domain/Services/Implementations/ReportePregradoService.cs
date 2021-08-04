using Data.Procedures;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ReportePregradoService : IReportePregradoService
    {
        public ReportePregradoService()
        {
        }

        public IEnumerable<PagoPregradoPorFacultadDTO> ReportePagosPorFacultad(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPregrado.PagosPorFacultad(fechaInicio, fechaFin, idEntidanFinanc);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPregrado_To_PagoPregradoPorFacultadDTO(p));

            return result;
        }

        public IEnumerable<PagoPregradoPorConceptoDTO> ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPregrado.PagosPorConcepto(fechaInicio, fechaFin, idEntidanFinanc);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPregrado_To_PagoPregradoPorConceptoDTO(p));

            return result;
        }

        public IEnumerable<ConceptoPregradoPorFacultadDTO> ReporteConceptosPorUnaFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPregrado.ConceptosPorUnaFacultad(codFac, fechaInicio, fechaFin, idEntidanFinanc);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPregrado_To_ConceptoPregradoPorFacultadDTO(p));

            return result;
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_ClasificadorDTO> ResumenAnualPagoOblig_X_Clasificadores(int anio)
        {
            var lista = USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores.Execute(anio, true);

            var result = lista.Select(
                x => Mapper.USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores_To_ResumenAnualPagoDeObligaciones_X_ClasificadorDTO(x));

            return result;
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_DependenciaDTO> ResumenAnualPagoOblig_X_Dependencia(int anio)
        {
            var lista = USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia.Execute(anio, true);

            var result = lista.Select(
                x => Mapper.USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia_To_ResumenAnualPagoDeObligaciones_X_DependenciaDTO(x));

            return result;
        }

        public IEnumerable<EstadoObligacionDTO> EstadoObligacionAlumnos(int anio, int? periodo, string codRc, bool? esIngresante, bool? estaPagado, bool? obligacionGenerada)
        {
            var pr = new USP_S_ListadoEstadoObligaciones_Parameters()
            {
                I_Anio = anio,
                I_Periodo = periodo,
                C_RcCod = codRc,
                B_EsPregrado = true,
                B_Ingresante = esIngresante,
                B_Pagado = estaPagado,
                B_ObligacionGenerada = obligacionGenerada
            };

            var lista = USP_S_ListadoEstadoObligaciones.Execute(pr);

            var result = lista.Select(x => Mapper.USP_S_ListadoEstadoObligaciones_To_EstadoObligacionDTO(x));

            return result;
        }
    }
}
