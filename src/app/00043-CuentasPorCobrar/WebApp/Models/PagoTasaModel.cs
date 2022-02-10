using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class PagoTasaModel
    {
        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string C_CodTasa { get; set; }

        public string T_ConceptoPagoDesc { get; set; }

        public string T_Clasificador { get; set; }

        public string C_CodClasificador { get; set; }

        public string T_ClasificadorDesc { get; set; }

        public decimal? M_Monto { get; set; }

        public string C_CodOperacion { get; set; }

        public string C_CodigoInterno { get; set; }

        public string C_CodDepositante { get; set; }

        public string T_NomDepositante { get; set; }

        public DateTime D_FecPago { get; set; }

        public decimal I_MontoPagado { get; set; }

        public decimal I_InteresMoratorio { get; set; }

        public decimal I_MontoTotalPagado
        {
            get
            {
                return I_MontoPagado + I_InteresMoratorio;
            }
        }

        public DateTime D_FecCre { get; set; }
    }
}