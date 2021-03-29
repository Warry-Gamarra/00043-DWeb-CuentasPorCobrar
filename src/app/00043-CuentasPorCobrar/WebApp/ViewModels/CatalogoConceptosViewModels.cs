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
        public string Clasificador { get; set; }
        public decimal Monto { get; set; }
        public decimal MontoMinimo { get; set; }
        public bool Habilitado { get; set; }
        public DateTime? FecModificacion { get; set; }


        public CatalogoConceptosViewModel() { }

        public CatalogoConceptosViewModel(ConceptoEntity concepto)
        {
            this.Id = concepto.I_ConceptoID;
            this.NombreConcepto = concepto.T_ConceptoDesc.ToUpper();
            this.Clasificador = string.IsNullOrEmpty(concepto.T_Clasificador) ? "-" : concepto.T_Clasificador;
            this.Habilitado = concepto.B_Habilitado;
            this.FecModificacion = concepto.D_FecMod ?? concepto.D_FecCre;
            this.Monto = concepto.I_Monto;
            this.MontoMinimo = concepto.I_MontoMinimo;
        }
    }


    public class CatalogoConceptosRegistroViewModel
    {
        public int? Id { get; set; }

        [Display(Name="Nombre del concepto")]
        [Required]
        [MaxLength(250)]
        public string NombreConcepto { get; set; }

        [Display(Name = "Codigo de clasificador (opcional)")]
        [MaxLength(50)]
        public string Clasificador { get; set; }

        [Display(Name = "Monto")]
        [Required]
        [Range(0, int.MaxValue)]
        public decimal Monto { get; set; }

        [Display(Name = "Monto mínimo")]
        [Range(0, int.MaxValue)]
        public decimal MontoMinimo { get; set; }

        [Display(Name = "Concepto de matrícula")]
        public bool EsMatricula { get; set; }

        [Display(Name = "Concepto de pago extemporáneo")]
        public bool Extemporaneo { get; set; }

        [Display(Name = "Agrupa conceptos")]
        public bool AgupaConceptos { get; set; }

        [Display(Name = "Concepto calculado")]
        public bool Calculado { get; set; }

        [Display(Name = "Agrupa conceptos")]
        public int TipoCalculo { get; set; }
        public int TipoObligacion { get; set; }

        public CatalogoConceptosRegistroViewModel() { }

        public CatalogoConceptosRegistroViewModel(ConceptoEntity concepto)
        {
            this.Id = concepto.I_ConceptoID;
            this.NombreConcepto = concepto.T_ConceptoDesc.ToUpper();
            this.Clasificador = concepto.T_Clasificador;
            this.Extemporaneo = concepto.B_EsPagoExtmp;
            this.EsMatricula = concepto.B_EsPagoMatricula;
            this.AgupaConceptos = concepto.B_ConceptoAgrupa;
            this.Monto = concepto.I_Monto;
            this.MontoMinimo = concepto.I_MontoMinimo;
            this.Calculado = concepto.B_Calculado;
            this.TipoCalculo = concepto.I_Calculado;
        }
    }

}