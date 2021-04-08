using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoObligacionEntity
    {
        public string C_CodOperacion { get; set; }
        public string T_NomDepositante { get; set; }
        public string C_Referencia { get; set; }
        public DateTime D_FecPago { get; set; }
        public int I_Cantidad { get; set; }
        public string C_Moneda { get; set; }
        public decimal I_MontoPago { get; set; }
        public string T_LugarPago { get; set; }
        public string C_CodAlu { get; set; }
        public string C_CodRc { get; set; }
        public int I_ProcesoID { get; set; }
        public DateTime D_FecVencto { get; set; }
    }
}
