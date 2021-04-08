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

        public int I_ObligacionAluID { get; set; }

        public int I_ProcesoID { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public string C_CodFac { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_ProcesoDesc { get; set; }

        public DateTime D_FecVencto { get; set; }

        public byte I_Prioridad { get; set; }

        public string C_Moneda { get; set; }

        public string C_Nivel { get; set; }

        public string C_TipoAlumno { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public bool B_Pagado { get; set; }

        public string C_CodOperacion { get; set; }

        public DateTime? D_FecPago { get; set; }

        public string T_LugarPago { get; set; }
    }
}
