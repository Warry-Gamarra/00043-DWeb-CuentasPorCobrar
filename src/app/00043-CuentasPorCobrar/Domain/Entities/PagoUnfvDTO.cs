using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoGeneralDTO
    {
        public string T_DependenciaDesc { get; set; }
        public string C_CodDependencia { get; set; }
        public decimal I_MontoTotal { get; set; }
        public string T_MontoTotal
        {
            get
            {
                return I_MontoTotal.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }
    }

    public class PagoPorConceptoDTO
    {
        public int I_ConceptoID { get; set; }
        public string C_CodClasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public string T_ClasificadorDesc { get; set; }
        public decimal I_MontoTotal { get; set; }
        public string T_MontoTotal
        {
            get
            {
                return I_MontoTotal.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }
    }

    public class ConceptoPorDependenciaDTO
    {
        public string T_DependenciaDesc { get; set; }
        public string C_CodDependencia { get; set; }
        public int I_ConceptoID { get; set; }
        public string C_CodClasificador { get; set; }
        public string T_ClasificadorDesc { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public int I_Cantidad { get; set; }
        public decimal I_MontoTotal { get; set; }
        public string T_MontoTotal
        {
            get
            {
                return I_MontoTotal.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }
    }
}
