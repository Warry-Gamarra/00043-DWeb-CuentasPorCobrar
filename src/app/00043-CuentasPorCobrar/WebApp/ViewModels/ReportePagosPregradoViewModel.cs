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
    public class PagosPregradoViewModel
    {
        public PagosPregradoViewModel()
        {
            var today = DateTime.Today;

            var firstDay = new DateTime(today.Year, today.Month, 1);

            fechaDesde = firstDay.ToString(FormatosDateTIme.BASIC_DATE);

            fechaHasta = today.ToString(FormatosDateTIme.BASIC_DATE);
        }

        [Required]
        public int reporte { get; set; }

        public string facultad { get; set; }

        [Required]
        public string fechaDesde { get; set; }

        public DateTime? fechaInicio {
            get
            {
                if (String.IsNullOrWhiteSpace(fechaDesde))
                    return null;

                return DateTime.Parse(fechaDesde, CultureInfo.CreateSpecificCulture("en-GB"));
            }
        }

        [Required]
        public string fechaHasta { get; set; }

        public DateTime? fechaFin {
            get
            {
                if (String.IsNullOrWhiteSpace(fechaHasta))
                    return null;

                return DateTime.Parse(fechaHasta, CultureInfo.CreateSpecificCulture("en-GB"));
            }
        }

        public ReportePagosPorFacultadViewModel reportePagosPorFacultadViewModel { get; set; }

        public ReportePagosPorConceptoViewModel reportePagosPorConceptoViewModel { get; set; }

        public ReporteConceptosPorUnaFacultadViewModel reporteConceptosPorUnaFacultadViewModel { get; set; }
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
            FechaActual = DateTime.Now.ToString(FormatosDateTIme.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTIme.BASIC_TIME);
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
            FechaActual = DateTime.Now.ToString(FormatosDateTIme.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTIme.BASIC_TIME);
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
            FechaActual = DateTime.Now.ToString(FormatosDateTIme.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTIme.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }
}