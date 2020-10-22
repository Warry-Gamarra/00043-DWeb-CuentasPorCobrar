using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class EntidadFinancieraViewModel
    {
        public int? Id { get; set; }
        public string NombreEntidad { get; set; }
        public bool Habilitado { get; set; }
        public DateTime FechaActualiza { get; set; }

        public EntidadFinancieraViewModel() { }

        public EntidadFinancieraViewModel(EntidadFinanciera entidadFinanciera)
        {
            this.Id = entidadFinanciera.Id;
            this.NombreEntidad = entidadFinanciera.Nombre;
            this.Habilitado = entidadFinanciera.Habilitado;
            this.FechaActualiza = entidadFinanciera.FechaActualiza.Value.Date;
        }

    }


    public class EntidadFinancieraRegistroViewModel
    {
        public int? Id { get; set; }
        [Display(Name = "Nombre de la Entidad")]
        [Required]
        public string NombreEntidad { get; set; }
        public bool Habilitado { get; set; }

        public EntidadFinancieraRegistroViewModel() { }

        public EntidadFinancieraRegistroViewModel(EntidadFinanciera entidadFinanciera)
        {
            this.Id = entidadFinanciera.Id;
            this.NombreEntidad = entidadFinanciera.Nombre;
            this.Habilitado = entidadFinanciera.Habilitado;
        }

    }
}