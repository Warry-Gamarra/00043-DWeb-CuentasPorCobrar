using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class MatriculaDTO
    {
        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string N_Grado { get; set; }

        public int I_MatAluID { get; set; }

        public string C_CodRc { get; set; }

        public string C_CodAlu { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_EstMat { get; set; }

        public string C_Ciclo { get; set; }

        public bool? B_Ingresante { get; set; }

        public byte? I_CredDesaprob { get; set; }

        public bool B_Habilitado { get; set; }
    }
}
