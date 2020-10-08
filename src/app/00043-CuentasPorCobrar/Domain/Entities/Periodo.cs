using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class Periodo
    {
        public int I_PeriodoID { get; set; }
        public string T_CuotaPagoDesc { get; set; }
        public int N_Anio { get; set; }
        public DateTime D_FecIni { get; set; }
        public DateTime D_FecFin { get; set; }
    }
}
