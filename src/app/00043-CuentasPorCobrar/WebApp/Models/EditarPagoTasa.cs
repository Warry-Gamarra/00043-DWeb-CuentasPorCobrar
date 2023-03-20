using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class EditarPagoTasa
    {
        public int I_PagoBancoID { get; set; }

        public int I_TasaUnfvID { get; set; }

        public string C_CodTasa { get; set; }

        public string T_ConceptoPagoDesc { get; set; }

        public decimal M_Monto { get; set; }

        public int? I_NuevaTasaUnfvID { get; set; }

        public string C_CodOperacion { get; set; }

        public string C_CodigoInterno { get; set; }

        public string C_CodDepositante { get; set; }

        public string T_NomDepositante { get; set; }

        public string T_EntidadDesc { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string T_FecPago { get; set; }

        public decimal I_MontoTotalPagado { get; set; }
    }
}