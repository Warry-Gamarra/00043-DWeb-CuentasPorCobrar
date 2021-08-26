using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ReportePregradoServiceFacade : IReportePregradoServiceFacade
    {
        IReportePregradoService reporteService;
        IEntidadRecaudadora entidadRecaudadoraService;

        public ReportePregradoServiceFacade()
        {
            reporteService = new ReportePregradoService();
            entidadRecaudadoraService = new EntidadRecaudadora();
        }

        public ReportePagosPorFacultadViewModel ReportePagosPorFacultad(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReportePagosPorFacultad(fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReportePagosPorFacultadViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Pregrado.First(x => x.Key.Equals(1)).Value
            };

            return reporte;
        }

        public ReportePagosPorConceptoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReportePagosPorConcepto(fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReportePagosPorConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Pregrado.First(x => x.Key.Equals(2)).Value
            };

            return reporte;
        }

        public ReporteConceptosPorUnaFacultadViewModel ReporteConceptosPorUnaFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReporteConceptosPorUnaFacultad(codFac, fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReporteConceptosPorUnaFacultadViewModel(pagos)
            {
                Facultad = pagos.Count() > 0 ? pagos.FirstOrDefault().T_FacDesc : "",
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Pregrado.First(x => x.Key.Equals(3)).Value
            };

            return reporte;
        }

        public ReporteResumenAnualPagoObligaciones_X_Clasificadores ResumenAnualPagoOblig_X_Clasificadores(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = reporteService.ResumenAnualPagoOblig_X_Clasificadores(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Clasificadores(anio, TipoEstudio.Pregrado, nombreEntidadFinanc, null, lista);

            return result;
        }

        public ReporteResumenAnualPagoObligaciones_X_Dependencias ResumenAnualPagoOblig_X_Dependencias(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = reporteService.ResumenAnualPagoOblig_X_Dependencia(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Dependencias(anio, TipoEstudio.Pregrado, nombreEntidadFinanc, null, lista);

            return result;
        }

        public IEnumerable<EstadoObligacionViewModel> EstadoObligacionAlumnos(int anio, int? periodo, string codFac, string codEsc, string codRc, 
            bool? esIngresante, bool? estaPagado, bool? obligacionGenerada, DateTime? fechaInicio, DateTime? fechaFin)
        {
            var lista = reporteService.EstadoObligacionAlumnos(anio, periodo, codFac, codEsc, codRc, esIngresante, estaPagado, obligacionGenerada, fechaInicio, fechaFin);

            var result = lista.Select(x => Mapper.EstadoObligacionDTO_To_EstadoObligacionViewModel(x));

            return result;
        }
    }
}