using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class PeriodoViewModel
    {
        public int I_PeriodoID { get; set; }
        public string T_TipoPerDesc { get; set; }
        public short? I_Anio { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public short? I_Prioridad { get; set; }
    }

    public class MantenimientoPeriodoViewModel
    {
        public int? I_PeriodoID { get; set; }

        [Display(Name = "Descripción")]
        public int I_TipoPeriodoID { get; set; }

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