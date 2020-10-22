using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PeriodoEntity
    {
        public int I_PeriodoID { get; set; }
        public int I_TipoPeriodoID { get; set; }
        public short? I_Anio { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public byte? I_Prioridad { get; set; }
        public bool B_Habilitado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public int? I_UsuarioMod { get; set; }
    }
}
