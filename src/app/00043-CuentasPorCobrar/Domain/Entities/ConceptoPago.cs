using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ConceptoPago
    {
        public int I_ConcPagID { get; set; }
        public string T_CatPagoDesc { get; set; }
        public string T_ConceptoDesc { get; set; }
        public string T_ProcesoDesc { get; set; }
        public int I_Anio { get; set; }
        public int I_Periodo { get; set; }
        public decimal M_MontoMinimo { get; set; }
        public decimal M_Monto { get; set; }
    }
}
