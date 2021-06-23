using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IReportePosgradoService
    {
        IEnumerable<PagoPosgradoPorGradodDTO> ReportePagosPorGrado(DateTime fechaInicio, DateTime fechaFin);

        IEnumerable<PagoPosgradoPorConceptoDTO> ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin);

        IEnumerable<ConceptoPosgradoPorGradoDTO> ReporteConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin);
    }
}
