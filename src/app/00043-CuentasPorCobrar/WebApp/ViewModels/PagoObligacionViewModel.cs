using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class PagoObligacionViewModel
    {
        [Required]
        public int anio { get; set; }

        [Required]
        public int idPeriodo { get; set; }

        [Required]
        public string codigoAlumno { get; set; }

        [Required]
        public string codRc { get; set; }

        [Required]
        public string nombreAlumno { get; set; }

        [Required]
        public int idOligacionCab { get; set; }

        [Required]
        public string codigoOperacion { get; set; }

        public string codigoReferencia { get; set; }

        [Required]
        public int idEntidadFinanciera { get; set; }

        [Required]
        public string fechaPago { get; set; }

        [Required]
        public string lugarPago { get; set; }

        public int cantidad { get { return 1; } }

        public string moneda { get { return "PEN";  } }

        public TipoPago tipoPago { get { return TipoPago.Obligacion; } }

        public PagoObligacionViewModel()
        {
            anio = DateTime.Now.Year;

            idPeriodo = 15;
        }
    }
}