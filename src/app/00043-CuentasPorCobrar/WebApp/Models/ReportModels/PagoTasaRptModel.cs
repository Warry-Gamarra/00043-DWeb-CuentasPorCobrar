using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.ReportModels
{
    public class PagoTasaRptModel
    {
        public string T_ConceptoPago { get; set; }

        public string T_Tasa { get; set; }

        public string T_TotalPagado { get; set; }
    }
}