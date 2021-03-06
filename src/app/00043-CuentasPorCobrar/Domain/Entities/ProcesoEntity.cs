using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ProcesoEntity
    {
        public int I_ProcesoID { get; set; }
        public int I_CatPagoID { get; set; }
        public int? I_Anio { get; set; }
        public int? I_Periodo { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public int? I_Prioridad { get; set; }
        public bool B_Habilitado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public int? I_UsuarioMod { get; set; }
    }
}
