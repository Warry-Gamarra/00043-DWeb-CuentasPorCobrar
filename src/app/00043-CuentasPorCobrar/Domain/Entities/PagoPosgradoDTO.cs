using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoPosgradoPorGradodDTO
    {
        public string T_EscDesc { get; set; }
        public string C_CodEsc { get; set; }
        public decimal I_MontoTotal { get; set; }
    }

    public class PagoPosgradoPorConceptoDTO
    {
        public int I_ConceptoID { get; set; }
        public string C_CodClasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal I_MontoTotal { get; set; }
    }

    public class ConceptoPosgradoPorGradoDTO
    {
        public string T_EscDesc { get; set; }
        public string C_CodEsc { get; set; }
        public int I_ConceptoID { get; set; }
        public string C_CodClasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public int I_Cantidad { get; set; }
        public decimal I_MontoTotal { get; set; }
    }
}
