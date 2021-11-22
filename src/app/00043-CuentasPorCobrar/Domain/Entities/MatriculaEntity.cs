using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class MatriculaEntity
    {
        public string C_CodRC { get; set; }
        public string C_CodAlu { get; set; }
        public int? I_Anio { get; set; }
        public string C_Periodo { get; set; }
        public string C_EstMat { get; set; }
        public string C_Ciclo { get; set; }
        public bool? B_Ingresante { get; set; }
        public int? I_CredDesaprob { get; set; }
        public string C_CodCurso { get; set; }
        public int? I_Vez { get; set; }
    }
}
