using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.ReportModels
{
    public class ObligacionAlumnoRptModel
    {
        public string T_ConceptoDesc { get; set; }

        public string T_NroOrden { get; set; }

        public string T_ProcesoDesc { get; set; }

        public string I_Monto { get; set; }

        public string T_FecVencto { get; set; }

        public string T_TipoObligacion { get; set; }

        public string T_Pagado { get; set; }

        public string T_NroRecibo { get; set; }

        public string T_FecPago { get; set; }

        public string T_LugarPago { get; set; }
    }
}