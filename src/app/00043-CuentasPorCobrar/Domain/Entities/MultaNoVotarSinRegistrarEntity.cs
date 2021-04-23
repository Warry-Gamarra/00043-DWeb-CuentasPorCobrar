using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class MultaNoVotarSinRegistrarEntity
    {
        public string C_CodRC { get; set; }
        public string C_CodAlu { get; set; }
        public int? I_Anio { get; set; }
        public string C_Periodo { get; set; }
        public bool B_Success { get; set; }
        public string T_Message { get; set; }
    }
}
