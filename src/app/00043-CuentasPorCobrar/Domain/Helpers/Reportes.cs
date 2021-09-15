using Data.Procedures;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public static class Reportes
    {
        public const string REPORTE_GENERAL = "G";

        public const string REPORTE_CONCEPTO = "C";

        public static Dictionary<string, string> Listar()
        {
            return new Dictionary<string, string>
            {
                { REPORTE_GENERAL, "Reporte de Pagos General" },
                { REPORTE_CONCEPTO, "Reporte de Pagos por Conceptos" }
            };
        }
    }
}

