using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IReporteUnfvService
    {
        IEnumerable<PagoGeneralDTO> ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito);

        IEnumerable<PagoPorConceptoDTO> ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito);

        IEnumerable<ConceptoPorDependenciaDTO> ReportePorDependenciaYConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito);

        IEnumerable<ConceptoPorDependenciaDTO> ReporteConceptosPorDependencia(string codDependencia, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito);

        IEnumerable<EstadoObligacionDTO> EstadoObligacionAlumnos(int anio, int? periodo, string codFac, string codEsc, string codRc, bool? esIngresante, bool? estaPagado, bool? obligacionGenerada, 
            DateTime? fechaInicio, DateTime? fechaFin, string codAlu, string nomAlu, string apePaternoAlumno, string apeMaternoAlumno, int? dependenciaID);
    }
}
