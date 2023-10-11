using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ReporteSegundaEspecialidadService : IReporteUnfvService
    {
        public IEnumerable<EstadoObligacionDTO> EstadoObligacionAlumnos(int anio, int? periodo, string codFac, string codEsc, string codRc, bool? esIngresante, bool? estaPagado, bool? obligacionGenerada, DateTime? fechaInicio, DateTime? fechaFin, string codAlu, string nomAlu, string apePaternoAlumno, string apeMaternoAlumno, int? dependenciaID)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<ConceptoPorDependenciaDTO> ReporteConceptosPorDependencia(string codDependencia, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<PagoGeneralDTO> ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<PagoPorConceptoDTO> ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<ConceptoPorDependenciaDTO> ReportePorDependenciaYConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_ClasificadorDTO> ResumenAnualPagoOblig_X_Clasificadores(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_DependenciaDTO> ResumenAnualPagoOblig_X_Dependencia(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            throw new NotImplementedException();
        }
    }
}
