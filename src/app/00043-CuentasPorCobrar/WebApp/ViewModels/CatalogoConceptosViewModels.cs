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
        public string ClasifCorto { get; set; }

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
            this.ClasifCorto = concepto.T_ClasifCorto;
        }
    }


    public class CatalogoConceptosRegistroViewModel
    {
        public int? Id { get; set; }

        [Display(Name="Nombre del concepto")]
        [Required]
        [MaxLength(250)]
        public string NombreConcepto { get; set; }

        [Display(Name = "Código de clasificador (opcional)")]
        [MaxLength(50)]
        public string Clasificador { get; set; }

        [Display(Name = "Código de tasa (opcional)")]
        [MaxLength(5, ErrorMessage = "El Código de tasa debe ser de 5 dígitos.")]
        [MinLength(5, ErrorMessage = "El Código de tasa debe ser de 5 dígitos.")]
        public string T_ClasifCorto { get; set; }

        [Display(Name = "Concepto de matrícula")]
        public bool EsMatricula { get; set; }

        [Display(Name = "Concepto de pago extemporáneo")]
        public bool Extemporaneo { get; set; }

        public bool B_EsObligacion { get; set; }

        public bool B_Fraccionable { get; set; }

        public bool B_ConceptoGeneral { get; set; }

        public bool B_AgrupaConcepto { get; set; }

        public int? TipoObligacion { get; set; }

        [Display(Name = "Concepto calculado")]
        public bool Calculado { get; set; }

        [Display(Name = "Agrupa conceptos")]
        public int TipoCalculo { get; set; }

        public bool B_GrupoCodRc { get; set; }

        [Display(Name = "Grupo Cod_Rc")]
        [RequiredWhenBoolenIsTrue("B_GrupoCodRc")]
        public int? I_GrupoCodRc { get; set; }

        public bool B_ModalidadIngreso { get; set; }

        [Display(Name = "Mod.Ingreso")]
        public int? I_ModalidadIngresoID { get; set; }

        [Display(Name = "Agrupa conceptos")]
        public bool AgupaConceptos { get; set; }

        public int? I_ConceptoAgrupaID { get; set; }

        public byte? N_NroPagos { get; set; }

        public bool B_Porcentaje { get; set; }

        public string C_Moneda { get; set; }

        [Display(Name = "Monto")]
        [Required]
        [Range(0, int.MaxValue)]
        public decimal Monto { get; set; }

        [Display(Name = "Monto mínimo")]
        [Range(0, int.MaxValue)]
        public decimal MontoMinimo { get; set; }

        public string T_DescripcionLarga { get; set; }

        public string T_Documento { get; set; }

        [Display(Name = "Mora")]
        public bool B_Mora { get; set; }

        public CatalogoConceptosRegistroViewModel()
        {
            C_Moneda = "PEN";
        }

        public CatalogoConceptosRegistroViewModel(ConceptoEntity concepto)
        {
            this.Id = concepto.I_ConceptoID;
            this.NombreConcepto = concepto.T_ConceptoDesc.ToUpper();
            this.Clasificador = concepto.T_Clasificador;
            this.T_ClasifCorto = concepto.T_ClasifCorto;
            this.B_EsObligacion = concepto.B_EsObligacion;
            this.EsMatricula = concepto.B_EsPagoMatricula;
            this.Extemporaneo = concepto.B_EsPagoExtmp;

            this.B_Fraccionable = concepto.B_Fraccionable ?? false;
            this.B_ConceptoGeneral = concepto.B_ConceptoGeneral ?? false;
            this.B_AgrupaConcepto = concepto.B_AgrupaConcepto ?? false;
            this.TipoObligacion = concepto.I_TipoObligacion;

            this.Calculado = concepto.B_Calculado;
            this.TipoCalculo = concepto.I_Calculado;
            this.B_GrupoCodRc = concepto.B_GrupoCodRc ?? false;
            this.I_GrupoCodRc = concepto.I_GrupoCodRc;
            this.B_ModalidadIngreso = concepto.B_ModalidadIngreso ?? false;
            this.I_ModalidadIngresoID = concepto.I_ModalidadIngresoID;

            this.AgupaConceptos = concepto.B_ConceptoAgrupa;
            this.I_ConceptoAgrupaID = concepto.I_ConceptoAgrupaID;

            this.N_NroPagos = concepto.N_NroPagos;
            this.B_Porcentaje = concepto.B_Porcentaje ?? false;
            this.C_Moneda = concepto.C_Moneda;
            this.Monto = concepto.I_Monto;
            this.MontoMinimo = concepto.I_MontoMinimo;
            
            this.T_DescripcionLarga = concepto.T_DescripcionLarga;
            this.T_Documento = concepto.T_Documento;
            this.B_Mora = concepto.B_Mora ?? false;
            
        }
    }

}