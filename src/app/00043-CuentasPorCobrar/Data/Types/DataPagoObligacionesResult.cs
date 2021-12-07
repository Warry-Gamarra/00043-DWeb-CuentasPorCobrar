using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Types
{
    public class DataPagoObligacionesResult
    {
        public int id { get; set; }
        public int? I_ProcesoID { get; set; }
        public int? I_ObligacionAluID { get; set; }
        public string C_CodOperacion { get; set; }
        public string C_CodDepositante { get; set; }
        public string T_NomDepositante { get; set; }
        public string C_Referencia { get; set; }
        public DateTime D_FecPago { get; set; }
        public DateTime D_FecVencto { get; set; }
        public int I_Cantidad { get; set; }
        public string C_Moneda { get; set; }
        public decimal? I_MontoOblig { get; set; }
        public decimal I_MontoPago { get; set; }
        public decimal I_InteresMora { get; set; }
        public string T_LugarPago { get; set; }
        public int I_EntidadFinanID { get; set; }
        public int? I_CtaDepositoID { get; set; }
        public bool? B_Pagado { get; set; }
        public bool B_Success { get; set; }
        public string T_ErrorMessage { get; set; }
        public string T_InformacionAdicional { get; set; }
        public string T_ProcesoDesc { get; set; }
        public int I_CondicionPagoID { get; set; }
    }
}
