using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class CtaDepoProcesoModel
    {
        public int I_CtaDepoProID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string T_DescCuenta { get; set; }

        public int I_ProcesoID { get; set; }

        public string T_ProcesoDesc { get; set; }

        public byte? I_Prioridad { get; set; }

        public short? I_Anio { get; set; }

        public int? I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_PeriodoDesc { get; set; }

        public int? I_Nivel { get; set; }

        public string C_Nivel { get; set; }

        public bool B_Habilitado { get; set; }
    }
}