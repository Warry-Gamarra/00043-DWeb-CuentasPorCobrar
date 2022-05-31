using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class EstadoObligacionDTO
    {
        public int I_MatAluID { get; set; }

        public int I_ObligacionAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string N_Grado { get; set; }

        public string C_CodFac { get; set; }

        public string T_FacDesc { get; set; }

        public string C_CodEsc { get; set; }

        public string T_EscDesc { get; set; }

        public string T_DenomProg { get; set; }

        public bool B_Ingresante { get; set; }

        public int I_CredDesaprob { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_ProcesoDesc { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public DateTime? D_FecVencto { get; set; }

        public bool? B_Pagado { get; set; }

        public decimal? I_MontoPagadoActual { get; set; }

        public DateTime D_FecCre { get; set; }

        public DateTime? D_FecMod { get; set; }

        public string T_FecPagos { get; set; }
    }
}
