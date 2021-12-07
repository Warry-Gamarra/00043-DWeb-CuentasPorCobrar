using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoObligacionDetalleDTO
    {
        public string C_CodOperacion { get; set; }

        public DateTime? D_FecPago { get; set; }

        public string T_LugarPago { get; set; }
    }
}
