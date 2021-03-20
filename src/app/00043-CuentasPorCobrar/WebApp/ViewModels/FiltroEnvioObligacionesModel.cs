using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class FiltroEnvioObligacionesModel
    {
        [Required]
        [Display(Name = "Año")]
        public int I_Anio { get; set; }

        [Required]
        [Display(Name = "Periodo")]
        public int I_Periodo { get; set; }

        [Required]
        [Display(Name = "Tipo de estudio")]
        public TipoEstudio E_TipoEstudio { get; set; }

        [Display(Name = "Facultad/Especialidades")]
        public string T_Facultad { get; set; }

        [Required]
        [Display(Name = "Banco")]
        public int I_EntidadFinanciera { get; set; }

        [Required]
        [Display(Name = "Fecha desde")]
        public string T_FechaDesde { get; set; }

        public DateTime? D_FechaDesde
        {
            get
            {
                if (String.IsNullOrWhiteSpace(T_FechaDesde))
                    return null;

                return  DateTime.Parse(T_FechaDesde, CultureInfo.CreateSpecificCulture("en-GB"));
            }
        }

        [Display(Name = "Fecha hasta")]
        public string T_FechaHasta { get; set; }

        public DateTime? D_FechaHasta
        {
            get
            {
                if (String.IsNullOrWhiteSpace(T_FechaHasta))
                    return null;

                return DateTime.Parse(T_FechaHasta, CultureInfo.CreateSpecificCulture("en-GB"));
            }
        }
    }
}