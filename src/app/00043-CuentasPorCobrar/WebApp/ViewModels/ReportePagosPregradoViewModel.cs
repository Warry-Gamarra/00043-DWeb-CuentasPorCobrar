using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class PagosPregradoViewModel
    {
        public ReportePagosPorFacultadViewModel reportePagosPorFacultadViewModel { get; }

        public ReportePagosPorConceptoViewModel reportePagosPorConceptoViewModel { get; }

        public ReporteConceptosPorUnaFacultadViewModel reporteConceptosPorUnaFacultadViewModel { get; }

        public PagosPregradoViewModel(ReportePagosPorFacultadViewModel reportePagosPorFacultadViewModel)
        {
            this.reportePagosPorFacultadViewModel = reportePagosPorFacultadViewModel;
        }

        public PagosPregradoViewModel(ReportePagosPorConceptoViewModel reportePagosPorConceptoViewModel)
        {
            this.reportePagosPorConceptoViewModel = reportePagosPorConceptoViewModel;
        }

        public PagosPregradoViewModel(ReporteConceptosPorUnaFacultadViewModel reporteConceptosPorUnaFacultadViewModel)
        {
            this.reporteConceptosPorUnaFacultadViewModel = reporteConceptosPorUnaFacultadViewModel;
        }
    }

    public class ReportePagosPorFacultadViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public IEnumerable<PagoPregradoPorFacultadDTO> listaPagos { get; }

        public ReportePagosPorFacultadViewModel(IEnumerable<PagoPregradoPorFacultadDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString("dd/MM/yyyy");
            HoraActual = DateTime.Now.ToString("HH:mm");
            this.listaPagos = listaPagos;
        }
    }

    public class ReportePagosPorConceptoViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public IEnumerable<PagoPregradoPorConceptoDTO> listaPagos { get; }

        public ReportePagosPorConceptoViewModel(IEnumerable<PagoPregradoPorConceptoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString("dd/MM/yyyy");
            HoraActual = DateTime.Now.ToString("HH:mm");
            this.listaPagos = listaPagos;
        }
    }

    public class ReporteConceptosPorUnaFacultadViewModel
    {
        public string Titulo { get; set; }
        public string Facultad { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public IEnumerable<ConceptoPregradoPorFacultadDTO> listaPagos { get; }

        public ReporteConceptosPorUnaFacultadViewModel(IEnumerable<ConceptoPregradoPorFacultadDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString("dd/MM/yyyy");
            HoraActual = DateTime.Now.ToString("HH:mm");
            this.listaPagos = listaPagos;
        }
    }
}