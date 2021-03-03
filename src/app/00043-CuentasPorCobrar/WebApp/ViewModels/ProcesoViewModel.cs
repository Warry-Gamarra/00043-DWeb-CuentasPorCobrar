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
        public int? Periodo { get; set; }
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
        public int[] PerAcadId { get; set; }
        [Display(Name = "Nro de Cta.Cte")]

        public int[] Arr_CtaDepositoID { get; set; }

        public bool? B_Habilitado { get; set; }
    }

    public class CategoriaProcesoViewModel
    {
        public int? Id { get; set; }
        public string Nombre { get; set; }
        public int CantidadProcesos { get; set; }
        public bool TieneProcesos { get; set; }
        public int CantidadConceptos { get; set; }
        public bool TieneConceptos { get; set; }
        public int Anio { get; set; }
        public int PeriodoId { get; set; }
    }

    public class ProcesoCategoriaViewModel
    {
        public int AnioProc { get; set; }
        public CategoriaPagoViewModel Categoria { get; set; }
        public List<ProcesoViewModel> Procesos { get; set; }
    }

    public class RegistroProcesoConceptosViewModel 
    {
        public int? ProcesoId { get; set; }
        public int? CategoriaId { get; set; }

        [Display(Name = "Descripción")]
        [Required]
        public string DescProceso { get; set; }

        [Display(Name = "Año")]
        public int? AnioProceso { get; set; }

        [Display(Name = "Fch. Vencimiento")]
        public DateTime? FecVencto { get; set; }

        [Display(Name = "Prioridad")]
        public int PrioridadId { get; set; }

        [Display(Name = "Periodo Académico")]
        public int[] PerAcadId { get; set; }

        [Display(Name = "Nro de Cta.Cte")]
        public int[] CtasDepoId { get; set; }

        public List<ConceptoPagoViewModel> Conceptos { get; set; }

    }
}