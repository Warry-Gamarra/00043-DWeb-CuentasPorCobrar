using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ObligacionDetalleDTO
    {
        public int I_ObligacionAluDetID { get; set; }

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

        public string C_CodModIng { get; set; }

        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_ProcesoDesc { get; set; }

        public string T_ConceptoDesc { get; set; }

        public string T_CatPagoDesc { get; set; }

        public decimal? I_Monto { get; set; }

        public bool B_Pagado { get; set; }

        public DateTime D_FecVencto { get; set; }

        public byte? I_Prioridad { get; set; }

        public string C_Moneda { get; set; }

        public int? I_TipoObligacion { get; set; }

        public int? I_Nivel { get; set; }

        public string C_Nivel { get; set; }

        public string T_Nivel { get; set; }

        public int? I_TipoAlumno { get; set; }

        public string C_TipoAlumno { get; set; }

        public string T_TipoAlumno { get; set; }

        public bool B_Mora { get; set; }

        public int? I_TipoDocumento { get; set; }

        public string T_DescDocumento { get; set; }

        public bool B_EsPagoMatricula { get; set; }
    }
}
