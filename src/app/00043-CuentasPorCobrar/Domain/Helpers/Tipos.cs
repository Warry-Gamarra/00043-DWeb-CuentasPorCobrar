using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public struct CuentaDepoEntidad
    {
        public int CuentaDepoId { get; set; }
        public int EntidadFinanId { get; set; }
    }


    public struct Posicion
    {
        public int Inicial { get; set; }
        public int Final { get; set; }
        public string ValorColumna { get; set; }
        public int Longitud
        {
            get
            {
                int length = (this.Final - this.Inicial < 0) ? 0 : this.Final - this.Inicial + 1;
                return length;
            }
        }

    }


    public class CabeceraArchivo
    {
        public string C_CodTipoRegistro { get; set; }
        public string T_CodCuenta { get; set; }
        public string N_NroCuenta { get; set; }
        public string D_FecProceso { get; set; }
        public string D_HoraProceso { get; set; }
        public string D_FecVencimiento { get; set; }
        public string C_Moneda { get; set; }
        public string I_NroRegistros1 { get; set; }
        public string I_NroRegistros2 { get; set; }
        public string I_TotalMonto1 { get; set; }
        public string I_TotalMonto2 { get; set; }
        public string T_InfoAdicional { get; set; }
        public string C_CodServicio { get; set; }
        public string C_CodBanco { get; set; }
        public string C_CodBcoUsuario { get; set; }
        public string I_CodBanco { get; set; }

    }

}
