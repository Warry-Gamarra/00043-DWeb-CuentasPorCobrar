using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ReportePagosObligacionesViewModel
    {
        public ReportePagosObligacionesViewModel()
        {
            tipoEstudio = TipoEstudio.Pregrado;

            var today = DateTime.Today;

            var firstDay = new DateTime(today.Year, today.Month, 1);

            fechaDesde = firstDay.ToString(FormatosDateTime.BASIC_DATE);

            fechaHasta = today.ToString(FormatosDateTime.BASIC_DATE);
        }

        [Required]
        public string tipoReporte { get; set; }

        public int reporte { get; set; }

        public TipoEstudio tipoEstudio { get; set; }

        public string dependencia { get; set; }

        public int? idEntidadFinanciera { get; set; }

        [Required]
        public string fechaDesde { get; set; }

        public DateTime? fechaInicio
        {
            get
            {
                if (String.IsNullOrWhiteSpace(fechaDesde))
                    return null;

                return DateTime.ParseExact(fechaDesde, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture);
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

                return DateTime.ParseExact(fechaHasta, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture);
            }
        }

        //Pregrado
        public ReportePagosPorFacultadViewModel reportePagosPorFacultadViewModel { get; set; }

        public ReportePagosPorConceptoViewModel reportePagosPorConceptoViewModel { get; set; }

        public ReporteConceptosPorUnaFacultadViewModel reporteConceptosPorUnaFacultadViewModel { get; set; }

        //Posgrado
        public ReportePagosPorGradodViewModel reportePagosPorGradodViewModel { get; set; }

        public ReportePagosPorConceptoPosgradoViewModel reportePagosPorConceptoPosgradoViewModel { get; set; }

        public ReporteConceptosPorGradoViewModel reporteConceptosPorGradoViewModel { get; set; }
    }
}