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
    public class ReportePosgradoServiceFacade : IReportePosgradoServiceFacade
    {
        IReportePosgradoService reporteService;
        IEntidadRecaudadora entidadRecaudadoraService;

        public ReportePosgradoServiceFacade()
        {
            reporteService = new ReportePosgradoService();
            entidadRecaudadoraService = new EntidadRecaudadora();
        }

        public ReportePagosPosgradoGeneralViewModel ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReporteGeneral(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            var reporte = new ReportePagosPosgradoGeneralViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos de Posgrado",
                nombreEntidadFinanc = nombreEntidadFinanc
            };

            return reporte;
        }

        public ReportePagosPosgradoPorConceptoViewModel ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReportePorConceptos(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            var reporte = new ReportePagosPosgradoPorConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos por Conceptos",
                nombreEntidadFinanc = nombreEntidadFinanc
            };

            return reporte;
        }

        public ReportePorGradoYConceptoViewModel ReportePorGradoYConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReportePorGradoYConcepto(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            var reporte = new ReportePorGradoYConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos por Grado",
                nombreEntidadFinanc = nombreEntidadFinanc
            };

            return reporte;
        }

        public ReporteConceptosPorGradoViewModel ReporteConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReporteConceptosPorGrado(codEsc, fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            var reporte = new ReporteConceptosPorGradoViewModel(pagos)
            {
                Grado = pagos.Count() > 0 ? pagos.FirstOrDefault().T_EscDesc : "",
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos de Conceptos por Grado",
                nombreEntidadFinanc = nombreEntidadFinanc
            };

            return reporte;
        }

        public ReporteResumenAnualPagoObligaciones_X_Clasificadores ResumenAnualPagoOblig_X_Clasificadores(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = reporteService.ResumenAnualPagoOblig_X_Clasificadores(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Clasificadores(anio, TipoEstudio.Posgrado, nombreEntidadFinanc, null, lista);

            return result;
        }

        public ReporteResumenAnualPagoObligaciones_X_Dependencias ResumenAnualPagoOblig_X_Dependencias(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = reporteService.ResumenAnualPagoOblig_X_Dependencia(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Dependencias(anio, TipoEstudio.Posgrado, nombreEntidadFinanc, null, lista);

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