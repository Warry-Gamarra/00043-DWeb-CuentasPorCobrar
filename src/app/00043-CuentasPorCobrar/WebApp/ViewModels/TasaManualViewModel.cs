using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class TasaManualViewModel
    {
        public string codigoDepositante { get; set; }

        public string nombreDepositante { get; set; }

        public int tasa { get; set; }

        public string codigoOperacion { get; set; }

        public string codigoReferencia { get; set; }

        public int idEntidadFinanciera { get; set; }

        public string fechaPago { get; set; }

        public string lugarPago { get; set; }

        public int cantidad { get { return 1; } }

        public string moneda { get { return "PEN"; } }

        public TipoPago tipoPago { get { return TipoPago.Tasa; } }
    }
}