using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.ReportModels
{
    public class PagoObligacionRptModel
    {
        public string T_ConceptoPago { get; set; }

        public string T_MontoPagado { get; set; }

        public string T_Mora { get; set; }

        public string T_TotalPagado { get; set; }
    }
}