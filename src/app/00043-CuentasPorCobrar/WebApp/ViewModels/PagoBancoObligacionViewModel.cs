using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class PagoBancoObligacionViewModel
    {
        public int I_PagoBancoID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int? I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string C_CodOperacion { get; set; }

        public string C_CodDepositante { get; set; }
        
        public int? I_MatAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string T_NomDepositante { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string T_CodDepositante
        {
            get
            {
                return I_MatAluID.HasValue ? C_CodAlu : C_CodDepositante;
            }
        }

        public string T_DatosDepositante
        {
            get
            {
                return I_MatAluID.HasValue ? 
                    String.Format("{1} {2}, {0}", T_Nombre, T_ApePaterno, T_ApeMaterno) : T_NomDepositante;
            }
        }

        public DateTime? D_FecPago { get; set; }

        public string T_FecPago
        {
            get
            {
                return D_FecPago.HasValue ? D_FecPago.Value.ToString(FormatosDateTime.BASIC_DATETIME) : "";
            }
        }

        public decimal I_MontoPago { get; set; }

        public string T_MontoPago
        {
            get
            {
                return I_MontoPago.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal I_InteresMora { get; set; }

        public string T_InteresMora
        {
            get
            {
                return I_InteresMora.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal I_MontoPagoTotal
        {
            get
            {
                return I_MontoPago + I_InteresMora;
            }
        }

        public string T_MontoPagoTotal
        {
            get
            {
                return I_MontoPagoTotal.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_LugarPago { get; set; }

        public DateTime D_FecCre { get; set; }

        public string T_Observacion { get; set; }

        public int I_CondicionPagoID { get; set; }

        public string T_Condicion { get; set; }

        public decimal I_MontoProcesado { get; set; }
    }
}