using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class EstadoObligacionViewModel
    {
        public int I_MatAluID { get; set; }

        public int I_ObligacionAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string T_NombresApellidos
        {
            get
            {
                return String.Format("{0} {1} {2}",
                    this.T_Nombre,
                    this.T_ApePaterno,
                    this.T_ApeMaterno);
            }
        }

        public string T_ApellidosNombres
        {
            get
            {
                return String.Format("{0} {1}, {2}",
                    this.T_ApePaterno,
                    this.T_ApeMaterno,
                    this.T_Nombre);
            }
        }

        public string N_Grado { get; set; }

        public string T_FacDesc { get; set; }

        public string T_EscDesc { get; set; }

        public string T_DenomProg { get; set; }

        public bool B_Ingresante { get; set; }

        public string T_EsIngresante
        {
            get
            {
                return B_Ingresante ? "Ingresante" : "Regular";
            }
        }

        public int I_CredDesaprob { get; set; }

        public int I_Anio { get; set; }

        public string T_Periodo { get; set; }

        public string T_ProcesoDesc { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public DateTime? D_FecVencto { get; set; }

        public string T_FecVencto
        {
            get
            {
                return D_FecVencto.HasValue ? D_FecVencto.Value.ToShortDateString() : "-";
            }
        }

        public bool? B_Pagado { get; set; }

        public string T_Pagado
        {
            get
            {
                return B_Pagado.HasValue ? (B_Pagado.Value ? "Pagd." : "Pendt.") : "-";
            }
        }

        public decimal? I_MontoPagadoActual { get; set; }
    }
}