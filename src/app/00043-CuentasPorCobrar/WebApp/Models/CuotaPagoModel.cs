using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class CuotaPagoModel
    {
        public int I_NroOrden { get; set; }

        public string T_NroOrden
        {
            get
            {
                return "P" + I_NroOrden.ToString("D2");
            }
        }

        public int I_ProcesoID { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string T_NombresCompletos
        {
            get
            {
                return (T_ApePaterno + " " + T_ApeMaterno).Trim() + " " + T_Nombre;
            }
        }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_CatPagoDesc { get; set; }

        public DateTime D_FecVencto { get; set; }

        public string T_FecVencto
        {
            get
            {
                return D_FecVencto.ToString("dd/MM/yyyy");
            }
        }

        public string C_Moneda { get; set; }

        public int I_TipoObligacion { get; set; }

        public string T_TipoObligacion
        {
            get
            {
                return I_TipoObligacion == 9 ? "Mat" : "Otr";
            }
        }

        public decimal? I_MontoTotal { get; set; }

        public string T_MontoTotal
        {
            get
            {
                return I_MontoTotal.HasValue ? I_MontoTotal.Value.ToString("N2") : "";
            }
        }
    }
}