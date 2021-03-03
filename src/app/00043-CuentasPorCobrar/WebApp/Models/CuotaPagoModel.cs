using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class CuotaPagoModel
    {
        public int I_ProcesoID { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public string T_Periodo { get; set; }

        public string T_CatPagoDesc { get; set; }

        public decimal? I_MontoTotal { get; set; }

        public string T_MontoTotal
        {
            get
            {
                return I_MontoTotal.HasValue ? I_MontoTotal.Value.ToString("N2") : "";
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
    }
}