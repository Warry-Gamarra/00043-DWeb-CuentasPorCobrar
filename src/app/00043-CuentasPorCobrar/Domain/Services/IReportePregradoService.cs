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

        IEnumerable<ResumenAnualPagoDeObligaciones_X_ClasificadorDTO> ResumenAnualPagoOblig_X_Clasificadores(int anio, int? entidadFinanID, int? ctaDepositoID);

        IEnumerable<ResumenAnualPagoDeObligaciones_X_DependenciaDTO> ResumenAnualPagoOblig_X_Dependencia(int anio, int? entidadFinanID, int? ctaDepositoID);

        IEnumerable<EstadoObligacionDTO> EstadoObligacionAlumnos(int anio, int? periodo, string codRc, bool? esIngresante, bool? estaPagado, bool? obligacionGenerada, DateTime? fechaInicio, DateTime? fechaFin);
    }
}
