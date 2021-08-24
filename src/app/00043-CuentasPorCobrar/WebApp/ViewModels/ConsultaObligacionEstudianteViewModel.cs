using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ConsultaObligacionEstudianteViewModel
    {
        public int? anio { get; set; }

        public int? periodo { get; set; }

        public string codFac { get; set; }

        public string codEsc { get; set; }

        public string codRc { get; set; }

        public string codAlumno { get; set; }

        public bool? esIngresante { get; set; }

        public bool? estaPagado { get; set; }

        public bool? obligacionGenerada { get; set; }

        public TipoEstudio tipoEstudio { get; set; }

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

        public IEnumerable<EstadoObligacionViewModel> resultado;

        public ConsultaObligacionEstudianteViewModel()
        {
            tipoEstudio = TipoEstudio.Pregrado;

            resultado = new List<EstadoObligacionViewModel>();
        }
    }
}