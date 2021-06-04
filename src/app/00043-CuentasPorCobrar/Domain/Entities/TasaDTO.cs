using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class TasaDTO
    {
        public int I_TasaUnfvID { get; set; }
        public string C_CodTasa { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal I_MontoTasa { get; set; }
        public string T_clasificador { get; set; }
        public bool B_Habilitado { get; set; }
    }
}
