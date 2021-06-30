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
        public static Dictionary<int, string> Pregrado
        {
            get
            {
                return new Dictionary<int, string>
                {
                    { USP_S_ReportePagoObligacionesPregrado.AgrupaPorFacultad, "Reporte de Pagos de Pregrado" },
                    { USP_S_ReportePagoObligacionesPregrado.AgrupaPorConcepto, "Reporte de Pagos por Conceptos" },
                    { USP_S_ReportePagoObligacionesPregrado.ConceptoPorUnaFacultad, "Reporte de Pagos de Conceptos por Facultad" }
                };
            }
        }

        public static Dictionary<int, string> Posgrado
        {
            get
            {
                return new Dictionary<int, string>
                {
                    { USP_S_ReportePagoObligacionesPosgrado.AgrupaPorGrado, "Reporte de Pagos de Posgrado" },
                    { USP_S_ReportePagoObligacionesPosgrado.AgrupaPorConcepto, "Reporte de Pagos por Conceptos" },
                    { USP_S_ReportePagoObligacionesPosgrado.ConceptoPorGrado, "Reporte de Pagos de Conceptos por Grado" }
                };
            }
        }
    }
}

