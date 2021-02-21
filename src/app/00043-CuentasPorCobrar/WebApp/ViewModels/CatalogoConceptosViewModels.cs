using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class CatalogoConceptosViewModel
    {
        public int? Id { get; set; }
        public string NombreConcepto { get; set; }
        public bool Habilitado { get; set; }
        public DateTime? FecModificacion { get; set; }


        public CatalogoConceptosViewModel() { }

        public CatalogoConceptosViewModel(ConceptoEntity concepto)
        {
            this.Id = concepto.I_ConceptoID;
            this.NombreConcepto = concepto.T_ConceptoDesc.ToUpper();
            this.Habilitado = concepto.B_Habilitado;
            this.FecModificacion = concepto.D_FecMod ?? concepto.D_FecCre;
        }
    }


    public class CatalogoConceptosRegistroViewModel
    {
        public int? Id { get; set; }

        [Display(Name="Nombre del concepto")]
        [Required]
        [MaxLength(250)]
        public string NombreConcepto { get; set; }

        [Display(Name = "¿Es un concepto de matrícula?")]
        public bool EsMatricula { get; set; }

        [Display(Name = "¿Aplica a pagos extemporáneos?")]
        public bool EsExtemporaneo { get; set; }

        [Display(Name = "¿Agrupa otros conceptos?")]
        public bool AgupaConceptos { get; set; }


        public CatalogoConceptosRegistroViewModel() { }

        public CatalogoConceptosRegistroViewModel(ConceptoEntity concepto)
        {
            this.Id = concepto.I_ConceptoID;
            this.NombreConcepto = concepto.T_ConceptoDesc.ToUpper();
            this.EsExtemporaneo = concepto.B_EsPagoExtmp;
            this.EsMatricula = concepto.B_EsPagoMatricula;
            this.AgupaConceptos = concepto.B_ConceptoAgrupa;
        }
    }

}