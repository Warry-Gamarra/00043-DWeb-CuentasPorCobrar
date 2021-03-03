using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ObligacionDetalleDTO
    {
        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_ConceptoDesc { get; set; }

        public string T_CatPagoDesc { get; set; }

        public decimal? I_Monto { get; set; }

        public bool B_Pagado { get; set; }

        public DateTime D_FecVencto { get; set; }

        public byte? I_Prioridad { get; set; }
    }
}
