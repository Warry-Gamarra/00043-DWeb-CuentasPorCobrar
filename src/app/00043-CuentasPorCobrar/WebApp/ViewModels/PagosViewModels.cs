using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class DatosPagoViewModel {
        public int PagoId { get; set; }

        [Display(Name = "Entidad recaudadora ")]
        public int EntidadRecaudadoraId { get; set; }

        public string EntidadRecaudadora { get; set; }

        [Display(Name = "Concepto ")]
        public string Concepto { get; set; }

        [Display(Name = "Lugar de pago")]
        public string LugarPago { get; set; }

        [Display(Name = "Fecha de pago")]
        public DateTime FecPago { get; set; }

        [Display(Name = "Monto")]
        public decimal MontoPago { get; set; }

        [Display(Name = "Nro SIAF")]
        public string NroSIAF { get; set; }
    }
}