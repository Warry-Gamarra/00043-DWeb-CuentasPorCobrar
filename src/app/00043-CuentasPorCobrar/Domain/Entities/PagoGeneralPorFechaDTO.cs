using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoGeneralPorFechaDTO
    {
        public int I_ConceptoID { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal I_MontoTotal { get; set; }
    }
}
