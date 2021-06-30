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
    }
}
