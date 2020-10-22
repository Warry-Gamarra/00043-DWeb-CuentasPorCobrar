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
        public int I_TipoPeriodoID { get; set; }
        public string T_TipoPerDesc { get; set; }
        public short? I_Anio { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public short? I_Prioridad { get; set; }
    }
}
