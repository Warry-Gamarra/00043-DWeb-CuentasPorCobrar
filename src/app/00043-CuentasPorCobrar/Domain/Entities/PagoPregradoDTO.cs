using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoPregradoPorFacultadDTO
    {
        public string T_FacDesc { get; set; }
        public string C_CodFac { get; set; }
        public decimal I_MontoTotal { get; set; }
    }

    public class PagoPregradoPorConceptoDTO
    {
        public int I_ConceptoID { get; set; }
        public string T_Clasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal I_MontoTotal { get; set; }
    }

    public class ConceptoPregradoPorFacultadDTO
    {
        public string T_FacDesc { get; set; }
        public string C_CodFac { get; set; }
        public int I_ConceptoID { get; set; }
        public string T_Clasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal I_MontoTotal { get; set; }
    }
}
