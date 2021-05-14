using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ReporteServiceFacade : IReporteServiceFacade
    {
        IReporteService reporteService;

        public ReporteServiceFacade()
        {
            reporteService = new ReporteService();
        }

        public ReportePagosGeneralesPorFecha ReportePagosGeneralesPorFecha(DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReportePagosGeneralPorFecha(fechaInicio, fechaFin);

            var reporte = new ReportePagosGeneralesPorFecha()
            {
                FechaInicio = fechaInicio.ToString("dd/MM/yyyy"),
                FechaFin = fechaFin.ToString("dd/MM/yyyy"),
                CuentaCorriente = "...",
                Titulo = "Reporte de Pagos por Cuenta Corriente",
                listaPagos = pagos.Select(p => Mapper.PagoGeneralPorFechaDTO_To_PagosGeneralesPorFechaViewModel(p))
            };

            return reporte;
        }

        public ReportePagosPorFacultadYFechaViewModel ReportePagosPorFacultadYFechaViewModel(string codFac, DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReportePagosPorFacultadYFecha(codFac, fechaInicio, fechaFin);

            var reporte = new ReportePagosPorFacultadYFechaViewModel()
            {
                CodFac = codFac,
                Facultad = "FACULTAD DE INGENIERÍA INDUSTRIAL Y DE SISTEMAS",
                FechaInicio = fechaInicio.ToString("dd/MM/yyyy"),
                FechaFin = fechaFin.ToString("dd/MM/yyyy"),
                CuentaCorriente = "...",
                Titulo = "Reporte de Pagos por Dependencia",
                listaPagos = pagos.Select(p => Mapper.PagoPorFacultadYFechaDTO_To_PagosPorFacultadYFechaViewModel(p))
            };

            return reporte;
        }
    }
}