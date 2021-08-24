using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IReportePosgradoServiceFacade
    {
        ReportePagosPorGradodViewModel ReportePagosPorGrado(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc);

        ReportePagosPorConceptoPosgradoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc);

        ReporteConceptosPorGradoViewModel ReporteConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc);

        ReporteResumenAnualPagoObligaciones_X_Clasificadores ResumenAnualPagoOblig_X_Clasificadores(int anio, int? entidadFinanID, int? ctaDepositoID);

        ReporteResumenAnualPagoObligaciones_X_Dependencias ResumenAnualPagoOblig_X_Dependencias(int anio, int? entidadFinanID, int? ctaDepositoID);

        IEnumerable<EstadoObligacionViewModel> EstadoObligacionAlumnos(int anio, int? periodo, string codRc, bool? esIngresante, bool? estaPagado, bool? obligacionGenerada, DateTime? fechaInicio, DateTime? fechaFin);
    }
}