using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ProcesoViewModel
    {
        public int I_ProcesoID { get; set; }
        public string T_CatPagoDesc { get; set; }
        public short? I_Anio { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public short? I_Prioridad { get; set; }
    }

    public class MantenimientoProcesoViewModel
    {
        public int? I_ProcesoID { get; set; }

        [Display(Name = "Descripción")]
        public int I_CatPagoID { get; set; }

        [Display(Name = "Año")]
        public short? I_Anio { get; set; }

        [Display(Name = "Fch. Vencimiento")]
        public DateTime? D_FecVencto { get; set; }

        [Display(Name = "Prioridad")]
        public byte? I_Prioridad { get; set; }

        [Display(Name = "Nro de Cta.Cte")]
        public int[] Arr_CtaDepositoID { get; set; }

        public bool? B_Habilitado { get; set; }
    }
}