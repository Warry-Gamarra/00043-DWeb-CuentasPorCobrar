using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class FiltroEnvioObligacionesViewModel
    {
        [Required]
        [Display(Name = "Año")]
        public int I_Anio { get; set; }

        [Required]
        [Display(Name = "Periodo")]
        public int? I_Periodo { get; set; }

        [Required]
        [Display(Name = "Tipo de estudio")]
        public TipoEstudio E_TipoEstudio { get; set; }

        [Display(Name = "Facultad/Posgrado")]
        public string T_Dependencia { get; set; }

        [Required]
        [Display(Name = "Banco")]
        public int I_EntidadFinanciera { get; set; }
    }
}