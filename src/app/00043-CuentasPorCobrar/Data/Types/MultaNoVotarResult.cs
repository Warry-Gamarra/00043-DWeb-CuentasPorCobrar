using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Types
{
    public class MultaNoVotarResult
    {
        public int? I_Anio { get; set; }
        public string C_Periodo { get; set; }
        public string C_CodAlu { get; set; }
        public string C_CodRC { get; set; }
        public bool B_Success { get; set; }
        public string T_Message { get; set; }
    }
}
