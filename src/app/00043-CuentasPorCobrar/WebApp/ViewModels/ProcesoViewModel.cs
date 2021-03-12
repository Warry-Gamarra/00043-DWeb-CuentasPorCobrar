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
        public string T_Periodo { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public short? I_Prioridad { get; set; }
    }

    public class RegistroProcesoViewModel
    {
        public int? ProcesoId { get; set; }

        [Display(Name = "Cuota de Pago")]
        [Required]
        public int? CategoriaId { get; set; }

        public string DescProceso { get; set; }

        [Display(Name = "Año")]
        public int Anio { get; set; }

        [Display(Name = "Fecha Vencimiento")]
        public DateTime? FecVencto { get; set; }

        [Display(Name = "Prioridad")]
        public int? PrioridadId { get; set; }

        [Display(Name = "Periodo Académico")]
        public int PerAcadId { get; set; }

        [Display(Name = "Nro de Cta.Cte")]
        public int[] CtaDepositoID { get; set; }

        [Display(Name = "Código Banco de Comercio")]
        public string CodBcoComercio { get; set; }

        public bool MostrarCodBanco { get; set; }
        public int[] CtasBcoComercio { get; set; }

    }


    public class RegistroConceptosProcesoViewModel 
    {
        public int ProcesoId { get; set; }
        public string DescProceso { get; set; }
        public bool MostrarFormulario { get; set; }

        public RegistroConceptoPagoViewModel ConceptoPago { get; set; }

        public RegistroConceptosProcesoViewModel()
        {
            this.ConceptoPago = new RegistroConceptoPagoViewModel();
            this.MostrarFormulario = true;
        }

    }
}