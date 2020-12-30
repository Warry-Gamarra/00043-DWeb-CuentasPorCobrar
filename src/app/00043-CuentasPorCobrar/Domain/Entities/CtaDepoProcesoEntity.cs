using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CtaDepoProcesoEntity
    {
        public int I_CtaDepoProID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_ProcesoID { get; set; }
        public bool B_Habilitado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public int? I_UsuarioMod { get; set; }
    }
}
