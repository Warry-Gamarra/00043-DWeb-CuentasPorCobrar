using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CuotaPagoDTO
    {
        public int I_NroOrden { get; set; }

        public int I_ProcesoID { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_CatPagoDesc { get; set; }

        public DateTime D_FecVencto { get; set; }

        public string C_Moneda { get; set; }

        public int I_TipoObligacion { get; set; }

        public decimal? I_MontoTotal { get; set; }
    }
}
