using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.ReportModels
{
    public class CabObligacionAlumnoRptModel
    {
        public string T_NroOrden { get; set; }

        public decimal I_MontoOblig { get; set; }

        public string T_MontoOblig { get; set; }

        public string T_FecVencto { get; set; }

        public bool B_Pagado { get; set; }

        public string T_Pagado { get; set; }

        public decimal I_MontoPagadoActual { get; set; }

        public string T_MontoPagadoActual { get; set; }
    }
}