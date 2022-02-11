using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoBancoObligacionDTO
    {
        public int I_PagoBancoID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int? I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string C_CodOperacion { get; set; }

        public string C_CodDepositante { get; set; }

        public int? I_ObligacionAluID { get; set; }

        public int? I_MatAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string T_NomDepositante { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public DateTime? D_FecPago { get; set; }

        public decimal I_MontoPago { get; set; }

        public decimal I_InteresMora { get; set; }

        public string T_LugarPago { get; set; }

        public DateTime D_FecCre { get; set; }

        public string T_Observacion { get; set; }

        public int I_CondicionPagoID { get; set; }

        public string T_Condicion { get; set; }

        public decimal I_MontoProcesado { get; set; }

        public string T_MotivoCoreccion { get; set; }

        public string C_CodigoInterno { get; set; }
    }
}
