using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ObligacionAluCabEntity
    {
        public int I_ObligacionAluID { get; set; }

        public int? I_ProcesoID { get; set; }

        public int? I_MatAluID { get; set; }

        public string C_Moneda { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public DateTime? D_FecVencto { get; set; }

        public bool? B_Pagado { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }
    }
}
