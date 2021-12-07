using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class ObligacionDetalleModel
    {
        public int? I_NroOrden { get; set; }

        public string T_NroOrden
        {
            get
            {
                return I_NroOrden.HasValue ? "P" + I_NroOrden.Value.ToString("D2") : "";
            }
        }

        public int I_ObligacionAluDetID { get; set; }

        public int I_ObligacionAluID { get; set; }

        public int I_ProcesoID { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public string C_CodFac { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_ProcesoDesc { get; set; }

        public string T_ConceptoDesc { get; set; }

        public string T_CatPagoDesc { get; set; }

        public decimal? I_Monto { get; set; }

        public string T_Monto
        {
            get
            {
                return I_Monto.HasValue ? I_Monto.Value.ToString("N2") : "";
            }
        }

        public bool B_Pagado { get; set; }

        public string T_Pagado
        {
            get
            {
                return B_Pagado ? "Pagd." : "Pendt.";
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

        public byte? I_Prioridad { get; set; }

        public string C_Moneda { get; set; }

        public int? I_TipoObligacion { get; set; }

        public string T_TipoObligacion
        {
            get
            {
                if (I_TipoObligacion.HasValue)
                    return I_TipoObligacion == 9 ? "Mat" : "Otr";
                else
                    return "";
            }
        }

        public int? I_Nivel { get; set; }

        public string C_Nivel { get; set; }

        public string T_Nivel { get; set; }

        public int? I_TipoAlumno { get; set; }

        public string C_TipoAlumno { get; set; }

        public string T_TipoAlumno { get; set; }

        public int? I_TipoDocumento { get; set; }

        public string T_DescDocumento { get; set; }

        public string T_NroRecibo { get; set; }

        public string D_FecPago { get; set; }

        public string T_LugarPago { get; set; }
    }
}