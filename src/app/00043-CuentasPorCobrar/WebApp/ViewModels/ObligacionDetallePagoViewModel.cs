using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ObligacionDetallePagoViewModel
    {
        public int I_MatAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string T_NombresCompletos
        {
            get
            {
                return ((T_ApePaterno + " " + T_ApeMaterno).Trim() + " " + T_Nombre).Trim();
            }
        }

        public int I_ProcesoID { get; set; }

        public string T_ProcesoDesc { get; set; }

        public int I_ObligacionAluID { get; set; }

        public decimal I_MontoOblig { get; set; }

        public string T_MontoOblig
        {
            get
            {
                return I_MontoOblig.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public int I_ObligacionAluDetID { get; set; }

        public int I_ConcPagID { get; set; }

        public string T_ConceptoPagoDesc { get; set; }

        public decimal I_Monto { get; set; }

        public string T_Monto
        {
            get
            {
                return I_Monto.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public DateTime D_FecVencto { get; set; }

        public string T_FecVencto
        {
            get
            {
                return D_FecVencto.ToString("dd/MM/yyyy");
            }
        }

        public int? I_TipoDocumento { get; set; }

        public string T_DescDocumento { get; set; }

        public decimal I_MontoPagado { get; set; }

        public string T_MontoPagado
        {
            get
            {
                return I_MontoPagado.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public int I_PagoBancoID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string C_CodOperacion { get; set; }

        public DateTime D_FecPago { get; set; }

        public string T_FecPago
        {
            get
            {
                return D_FecPago.ToString(FormatosDateTime.BASIC_DATETIME);
            }
        }

        public string T_LugarPago { get; set; }

        public DateTime D_FecCre { get; set; }

        public string T_FecCre
        {
            get
            {
                return D_FecCre.ToString(FormatosDateTime.BASIC_DATETIME);
            }
        }

        public string T_Observacion { get; set; }

        public byte I_Prioridad { get; set; }
    }
}