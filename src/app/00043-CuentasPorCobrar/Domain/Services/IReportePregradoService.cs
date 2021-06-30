using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IReportePregradoService
    {
        IEnumerable<PagoPregradoPorFacultadDTO> ReportePagosPorFacultad(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc);

        IEnumerable<PagoPregradoPorConceptoDTO> ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc);

        IEnumerable<ConceptoPregradoPorFacultadDTO> ReporteConceptosPorUnaFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc);
    }
}
