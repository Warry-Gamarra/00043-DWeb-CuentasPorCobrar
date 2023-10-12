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
        ReportePagosUnfvGeneralViewModel ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio);

        ReportePagosUnfvPorConceptoViewModel ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio);

        ReportePorDependenciaYConceptoViewModel ReportePorDependenciaYConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio);

        ReporteConceptosPorDependenciaViewModel ReporteConceptosPorDependencia(string codDep, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio);

        ReporteResumenAnualPagoObligaciones_X_Clasificadores ResumenAnualPagoOblig_X_Clasificadores(int anio, TipoEstudio tipoEstudio, int? entidadFinanID, int? ctaDepositoID);

        ReporteResumenAnualPagoObligaciones_X_Dependencias ResumenAnualPagoOblig_X_Dependencias(int anio, TipoEstudio tipoEstudio, int? entidadFinanID, int? ctaDepositoID);

        IEnumerable<EstadoObligacionViewModel> EstadoObligacionAlumnos(ConsultaObligacionEstudianteViewModel parametro);
    }
}