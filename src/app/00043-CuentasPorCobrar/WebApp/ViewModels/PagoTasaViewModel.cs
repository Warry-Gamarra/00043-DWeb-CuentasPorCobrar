using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class PagoTasaViewModel
    {
        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string codigoDepositante { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string nombreDepositante { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int tasa { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string codigoOperacion { get; set; }

        public string codigoReferencia { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int idEntidadFinanciera { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public int idCtaDeposito { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public DateTime? fechaPago { get; set; }

        public int horas { get; set; }

        public int minutos { get; set; }

        [Required(ErrorMessage = "Este campo es obligatorio.")]
        public string lugarPago { get; set; }

        public int cantidad { get; set; }

        public string moneda { get { return "PEN"; } }

        public TipoPago tipoPago { get { return TipoPago.Tasa; } }
    }
}