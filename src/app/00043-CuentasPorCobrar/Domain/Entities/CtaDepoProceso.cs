using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CtaDepoProceso
    {
        public int I_CtaDepoProID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_ProcesoID { get; set; }
        public bool B_Habilitado { get; set; }
        public string T_DescCuenta { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string T_EntidadDesc { get; set; }
    }
}
