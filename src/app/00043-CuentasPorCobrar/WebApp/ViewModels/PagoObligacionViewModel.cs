using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class PagoObligacionViewModel
    {
        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int anio { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int idPeriodo { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string codigoAlumno { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string codRc { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string nombreAlumno { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int idOligacionCab { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string codigoOperacion { get; set; }

        public string codigoReferencia { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int idEntidadFinanciera { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int idCtaDeposito { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string fechaPago { get; set; }

        public DateTime fechaPagoObl
        {
            get
            {
                return DateTime.ParseExact(fechaPago, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture).AddHours(horas).AddMinutes(minutos);
            }
        }

        public int horas { get; set; }

        public int minutos { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string lugarPago { get; set; }

        public int cantidad { get { return 1; } }

        public string moneda { get { return "PEN";  } }

        public TipoPago tipoPago { get { return TipoPago.Obligacion; } }

        public string observacion { get; set; }

        public PagoObligacionViewModel()
        {
            anio = DateTime.Now.Year;

            idPeriodo = 15;
        }
    }
}