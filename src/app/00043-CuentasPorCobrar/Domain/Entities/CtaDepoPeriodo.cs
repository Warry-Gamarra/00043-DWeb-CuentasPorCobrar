using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CtaDepoPeriodo
    {
        public int I_CtaDepoPerID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_PeriodoID { get; set; }
        public bool B_Habilitado { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string T_EntidadDesc { get; set; }
    }
}
