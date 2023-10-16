using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IReporteServiceFacade
    {
        ReportePagosUnfvGeneralViewModel ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio, out string tituloVista);

        ReportePagosUnfvPorConceptoViewModel ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio, out string tituloVista);

        ReportePorDependenciaYConceptoViewModel ReportePorDependenciaYConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio, out string tituloVista);

        ReporteConceptosPorDependenciaViewModel ReporteConceptosPorDependencia(string codDep, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio, out string tituloVista);

        IEnumerable<EstadoObligacionViewModel> EstadoObligacionAlumnos(ConsultaObligacionEstudianteViewModel parametro);
    }
}