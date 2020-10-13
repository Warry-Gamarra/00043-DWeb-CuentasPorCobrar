using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CuotaPago
    {
        public int I_CuotaPagoID { get; set; }
        public string T_CuotaPagoDesc { get; set; }
        public bool B_Habilitado { get; set; }
    }
}
