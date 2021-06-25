using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class PagosPosgradoViewModel
    {
        public PagosPosgradoViewModel()
        {
            var today = DateTime.Today;

            var firstDay = new DateTime(today.Year, today.Month, 1);

            fechaDesde = firstDay.ToString(FormatosDateTime.BASIC_DATE);

            fechaHasta = today.ToString(FormatosDateTime.BASIC_DATE);
        }

        [Required]
        public int reporte { get; set; }

        public string posgrado { get; set; }

        [Required]
        public string fechaDesde { get; set; }

        public DateTime? fechaInicio
        {
            get
            {
                if (String.IsNullOrWhiteSpace(fechaDesde))
                    return null;

                return DateTime.Parse(fechaDesde, CultureInfo.CreateSpecificCulture("en-GB"));
            }
        }

        [Required]
        public string fechaHasta { get; set; }

        public DateTime? fechaFin
        {
            get
            {
                if (String.IsNullOrWhiteSpace(fechaHasta))
                    return null;

                return DateTime.Parse(fechaHasta, CultureInfo.CreateSpecificCulture("en-GB"));
            }
        }

        public ReportePagosPorGradodViewModel reportePagosPorGradodViewModel { get; set; }

        public ReportePagosPorConceptoPosgradoViewModel reportePagosPorConceptoPosgradoViewModel { get; set; }

        public ReporteConceptosPorGradoViewModel reporteConceptosPorGradoViewModel { get; set; }
    }



    public class ReportePagosPorGradodViewModel
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
        public IEnumerable<PagoPosgradoPorGradodDTO> listaPagos { get; }

        public ReportePagosPorGradodViewModel(IEnumerable<PagoPosgradoPorGradodDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReportePagosPorConceptoPosgradoViewModel
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
        public IEnumerable<PagoPosgradoPorConceptoDTO> listaPagos { get; }

        public ReportePagosPorConceptoPosgradoViewModel(IEnumerable<PagoPosgradoPorConceptoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReporteConceptosPorGradoViewModel
    {
        public string Titulo { get; set; }
        public string Grado { get; set; }
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
        public IEnumerable<ConceptoPosgradoPorGradoDTO> listaPagos { get; }

        public ReporteConceptosPorGradoViewModel(IEnumerable<ConceptoPosgradoPorGradoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }
}