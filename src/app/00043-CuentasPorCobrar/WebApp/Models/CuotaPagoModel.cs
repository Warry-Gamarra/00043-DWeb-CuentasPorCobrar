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

        public int I_ObligacionAluID { get; set; }

        public int I_ProcesoID { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public string C_CodFac { get; set; }

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

        public string T_ProcesoDesc { get; set; }

        public DateTime D_FecVencto { get; set; }

        public string T_FecVencto
        {
            get
            {
                return D_FecVencto.ToString("dd/MM/yyyy");
            }
        }

        public byte I_Prioridad { get; set; }

        public string C_Moneda { get; set; }

        public string C_Nivel { get; set; }

        public string C_TipoAlumno { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public string T_MontoOblig
        {
            get
            {
                return I_MontoOblig.HasValue ? I_MontoOblig.Value.ToString("N2") : "";
            }
        }

        public bool B_Pagado { get; set; }

        public string C_CodOperacion { get; set; }

        public DateTime? D_FecPago { get; set; }

        public string T_FecPago
        {
            get
            {
                return D_FecPago.HasValue ? D_FecPago.Value.ToString("dd/MM/yyyy HH:mm") : "";
            }
        }

        public string T_LugarPago { get; set; }
    }
}