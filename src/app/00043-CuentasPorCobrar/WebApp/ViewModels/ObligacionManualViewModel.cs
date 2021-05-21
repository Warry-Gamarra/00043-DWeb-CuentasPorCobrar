using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ObligacionManualViewModel
    {
        public int anio { get; set; }

        public int idPeriodo { get; set; }

        public string codigoAlumno { get; set; }

        public string codRc { get; set; }

        public string nombreAlumno { get; set; }

        public int idOligacionCab { get; set; }

        public string codigoOperacion { get; set; }

        public string codigoReferencia { get; set; }

        public int idEntidadFinanciera { get; set; }

        public string fechaPago { get; set; }

        public string lugarPago { get; set; }

        public int cantidad { get { return 1; } }

        public string moneda { get { return "PEN";  } }

        public TipoPago tipoPago { get { return TipoPago.Obligacion; } }

        public ObligacionManualViewModel()
        {
            anio = DateTime.Now.Year;

            idPeriodo = 15;
        }
    }
}