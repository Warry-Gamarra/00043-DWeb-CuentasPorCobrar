using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class DependenciaViewModel
    {
        public int? DependenciaID { get; set; }

        public string CodDep { get; set; }

        public string DependDesc { get; set; }
        public string TipoDependencia { get; set; }

        public bool B_Habilitado { get; set; }
        public bool Academico { get; set; }


        public DependenciaViewModel() { }

        public DependenciaViewModel(Dependencia model)
        {
            this.DependenciaID = model.Id;
            this.CodDep = model.Codigo;
            this.DependDesc = model.Descripcion;
            this.TipoDependencia = model.EsAcademico ? "ACADÉMICO" : "ADMINISTRATIVO";
            this.Academico = model.EsAcademico;
            this.B_Habilitado = model.Habilitado;
        }
    }


    public class DependenciaRegistroViewModel
    {
        public int? DependenciaID { get; set; }

        [Display(Name = "Código ")]
        public string CodDep { get; set; }

        [Display(Name = "Código PL")]
        public string CodDepPL { get; set; }

        [Display(Name = "Siglas")]
        public string DependAbrev { get; set; }

        [Display(Name = "Nombre")]
        public string DependDesc { get; set; }

        [Display(Name = "Dependencia Académica")]
        public bool Academico { get; set; }



        public DependenciaRegistroViewModel() { }

        public DependenciaRegistroViewModel(Dependencia model)
        {
            this.DependenciaID = model.Id;
            this.CodDep = model.Codigo;
            this.CodDepPL = model.CodigoPl;
            this.DependAbrev = model.Abreviatura;
            this.Academico = model.EsAcademico;
        }
    }
}