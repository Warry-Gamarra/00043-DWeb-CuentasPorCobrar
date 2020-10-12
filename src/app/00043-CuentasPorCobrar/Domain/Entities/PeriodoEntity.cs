using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PeriodoEntity
    {
        public int I_PeriodoID { get; set; }
        public int I_CuotaPagoID { get; set; }
        public short N_Anio { get; set; }
        public DateTime D_FecIni { get; set; }
        public DateTime D_FecFin { get; set; }
        public bool B_Habilitado { get; set; }
    }
}
